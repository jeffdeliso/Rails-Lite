#!/usr/bin/env ruby
require 'fileutils'

directory = File.dirname(__FILE__)
source = File.join(directory, "..", "..")
FileUtils.cp_r source, FileUtils.pwd