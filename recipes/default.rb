#
# Cookbook Name:: chocolatey
# recipe:: default
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 2012, Societe Publica.
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

include_recipe "powershell"

powershell "install chocolatey" do
  code 'iex ((new-object net.webclient).DownloadString("https://raw.github.com/chocolatey/chocolatey/master/chocolateyInstall/InstallChocolatey.ps1"))'
  notifies :create, "ruby_block[reload path]", :immediately
  not_if { ::File.exist?( ::File.join(ENV['SYSTEMDRIVE'], "Chocolatey", "bin") ) }
end

ruby_block "reload path" do
  block do
    require 'Win32API'
    #see: http://msdn.microsoft.com/en-us/library/ms682653%28VS.85%29.aspx
    HWND_BROADCAST = 0xffff
    WM_SETTINGCHANGE = 0x001A
    SMTO_BLOCK = 0x0001
    SMTO_ABORTIFHUNG = 0x0002
    SMTO_NOTIMEOUTIFNOTHUNG = 0x0008
    result = 0
    flags = SMTO_BLOCK | SMTO_ABORTIFHUNG | SMTO_NOTIMEOUTIFNOTHUNG
    @send_message ||= Win32API.new('user32', 'SendMessageTimeout', 'LLLPLLP', 'L')
    @send_message.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', flags, 5000, result)
  end
  action :create
  only_if { RUBY_PLATFORM =~ /mswin|mingw32|windows/ }
end
