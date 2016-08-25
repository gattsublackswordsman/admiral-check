# -*- encoding: utf-8 -*-
#

require 'mixlib/shellout'

module Admiral
  module Shell
    def self.local(cmd, options={}, live = false)
      sh = Mixlib::ShellOut.new(cmd, options)

      if live
        sh.live_stdout = STDOUT
      end

      sh.run_command
      if sh.error?
        puts "Failed to run #{cmd}"
        puts sh.stderr
        return nil
      else
        return sh.stdout
      end
    end

    def self.remote (host, username, keyfile, cmd)
      Kernel.exec("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{username}@#{host} -i #{keyfile}")
    end
  end
end

