# frozen_string_literal: true

require 'forwardable'
require 'fileutils'
require 'digest'
require 'sys/filesystem'

require 'files/version'

module Files
  # delegate class methods
  extend SingleForwardable
  extend Sys

  class << self
    # list of file basenames in specified dir
    def filenames dir
      Dir[File.join(dir, '*')]
        .select { |f| File.file?(f) }
        .map { |f| basename(f) }
    end

    # return free space in bytes
    def free_space path
      mount_point = Filesystem.mount_point(path)
      stat = Filesystem.stat(mount_point)
      stat.block_size * stat.blocks_available
    end

    def md5 path
      Digest::MD5.file(path).hexdigest
    end

    # open in append mode
    def open path
      File.open(path, 'a')
    end

    # overwrite existing file
    def write path, string
      File.write(path, string, mode: 'w')
    end

    # don't use ruby-fifo gem because of its loading problems
    def write_to_fifo path, string
      # make fifo file writeable (just in case)
      FileUtils.chmod(0o666, path)
      # '+' means non-blocking mode
      File.open(path, 'w+') do |file|
        # don't use File#write - string must be newline terminated
        file.puts(string)
        file.flush
      end
    end
  end

  def_delegator :File, :basename
  # http://stackoverflow.com/questions/6553392
  # use FileUtils.rm instead of File.delete
  def_delegator :File, :exist?
  def_delegator :File, :join
  def_delegator :File, :read
  def_delegator :File, :size
  def_delegator :FileUtils, :mkdir_p
  def_delegator :FileUtils, :mv
  # raises exception if file doesn't exist
  def_delegator :FileUtils, :rm
  # doesn't raise exception if file doesn't exist
  def_delegator :FileUtils, :rm_f
  def_delegator :FileUtils, :touch
end
