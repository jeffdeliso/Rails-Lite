
require 'fileutils'

p directory = File.dirname(__FILE__)
p source = File.join(directory, "..", "..")
p FileUtils.pwd
FileUtils.cp_r source, FileUtils.pwd