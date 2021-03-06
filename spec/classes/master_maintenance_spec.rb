require 'spec_helper'

describe 'puppet::master::maintenance' do

  describe 'class puppet::master::maintenance' do

    context 'Puppetmaster maintenance cron' do
      let(:facts) { { :puppet_reportdir => '/var/lib/puppet/reports' } }

      it { should contain_class('puppet::master::maintenance') }

      it { should contain_cron('filebucket_cleanup').with({
          'user'    => 'root',
          'hour'    => '0',
          'minute'  => '0',
        })
      }
    end
  end

  describe 'purge reportdir' do
    context 'with default settings for params' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :puppet_reportdir       => '/var/lib/puppet/reports',
        }
      end

      it { should contain_class('puppet::master::maintenance') }

      it { should contain_cron('purge_old_puppet_reports').with({
          'ensure'  => 'present',
          'command' => '/usr/bin/find -L /var/lib/puppet/reports -type f -mtime +30 -exec /bin/rm -fr {} \;',
          'user'    => 'root',
          'hour'    => '0',
          'minute'  => '15',
        })
      }
    end

    context 'with reportdir_purge_user, reportdir_purge_hour, and reportdir_purge_minute set' do
      let(:params) do
        { :reportdir_purge_user   => 'gh',
          :reportdir_purge_hour   => '23',
          :reportdir_purge_minute => '42',
        }
      end
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :puppet_reportdir       => '/var/lib/puppet/reports',
        }
      end

      it { should contain_class('puppet::master::maintenance') }

      it { should contain_cron('purge_old_puppet_reports').with({
          'ensure'  => 'present',
          'command' => '/usr/bin/find -L /var/lib/puppet/reports -type f -mtime +30 -exec /bin/rm -fr {} \;',
          'user'    => 'gh',
          'hour'    => '23',
          'minute'  => '42',
        })
      }
    end

    describe 'with reportdir_days_to_keep specified' do
      context 'as a valid integer greater than zero' do
        let(:params) { { :reportdir_days_to_keep => '42' } }
        let(:facts) do
          { :osfamily               => 'RedHat',
            :operatingsystemrelease => '6.4',
            :puppet_reportdir       => '/var/lib/puppet/reports',
          }
        end

        it { should contain_class('puppet::master::maintenance') }

        it { should contain_cron('purge_old_puppet_reports').with({
            'ensure'  => 'present',
            'command' => '/usr/bin/find -L /var/lib/puppet/reports -type f -mtime +42 -exec /bin/rm -fr {} \;',
            'user'    => 'root',
            'hour'    => '0',
            'minute'  => '15',
          })
        }
      end

      ['0','-23'].each do |value|
        context "as #{value}" do
          let(:params) { { :reportdir_days_to_keep => value } }
          let(:facts) do
            { :osfamily               => 'RedHat',
              :operatingsystemrelease => '6.4',
              :puppet_reportdir       => '/var/lib/puppet/reports',
            }
          end

          it do
            expect {
              should contain_class('puppet::master::maintenance')
            }.to raise_error(Puppet::Error,/puppet::master::maintenance::reportdir_days_to_keep must be a positive integer greater than zero. Detected value is <#{value}>./)
          end
        end
      end
    end

    describe 'with reportdir specified' do
      context 'as a valid directory' do
        let(:params) { { :reportdir => '/etc/puppet/reports' } }
        let(:facts) do
          { :osfamily               => 'RedHat',
            :operatingsystemrelease => '6.4',
            :puppet_reportdir       => '/var/lib/puppet/reports',
          }
        end

        it { should contain_class('puppet::master::maintenance') }

        it { should contain_cron('purge_old_puppet_reports').with({
            'ensure'  => 'present',
            'command' => '/usr/bin/find -L /etc/puppet/reports -type f -mtime +30 -exec /bin/rm -fr {} \;',
            'user'    => 'root',
            'hour'    => '0',
            'minute'  => '15',
          })
        }
      end

      context 'as an invalid directory' do
        let(:params) { { :reportdir => 'invalid/path' } }
        let(:facts) do
          { :osfamily               => 'RedHat',
            :operatingsystemrelease => '6.4',
            :puppet_reportdir       => '/var/lib/puppet/reports',
          }
        end

        it do
          expect {
            should contain_class('puppet::master::maintenance')
          }.to raise_error(Puppet::Error)
        end
      end
    end

    context 'with reportdir and reportdir_days_to_keep specified' do
      let(:params) do
        { :reportdir              => '/etc/puppet/reports',
          :reportdir_days_to_keep => '42',
        }
      end
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :puppet_reportdir       => '/var/lib/puppet/reports',
        }
      end

      it { should contain_class('puppet::master::maintenance') }

      it { should contain_cron('purge_old_puppet_reports').with({
          'ensure'  => 'present',
          'command' => '/usr/bin/find -L /etc/puppet/reports -type f -mtime +42 -exec /bin/rm -fr {} \;',
          'user'    => 'root',
          'hour'    => '0',
          'minute'  => '15',
        })
      }
    end
  end
end
