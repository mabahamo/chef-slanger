#
# Cookbook Name:: slanger
# Recipe:: default
#
# Copyright 2012, Rafael Durán Castañeda
# Copyright 2015, Manuel Bahamóndez Honores
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# A user for running the service
user 'slanger' do
  comment     'slanger system user'
  system      true
  shell       '/bin/false'
  home        node[:slanger][:home_dir]
  manage_home true
end

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.5" do
  ruby_version "2.1.5"
  global true
end

rbenv_gem "bundler"
rbenv_gem "slanger"

# An upstart job for running slanger
# Restart doesn't work properly so we stop the service and the service
# definition starts it, ugly hack but it works.
template  '/etc/init/slanger.conf' do
  source  'etc/init/slanger.conf.erb'
  mode    '0644'
  owner   'root'
  group   'root'
  variables({
    :verbose => '-v',
  })
  notifies :stop, 'service[slanger]', :immediately
end



service 'slanger' do
  provider  Chef::Provider::Service::Upstart
  supports  :status => true, :restart => false, :start => true
  action    [ :enable, :start ]
end
