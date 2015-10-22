class Cleaner
  def initialize(path)
    @path = path
  end
  def clean
     @files = {}
     files_in @path
     @deleted = {}
     @files.each do |name, size|
        # get all the duplicates for the current file
        duplicates = @files.select {|key, val| val == size}
        next if duplicates.length <= 1
        # save the first one in a variable
        saved = duplicates.first
        # for each duplicated file delete it if the name of the file doesn't match with the saved file
        duplicates.each do |key, val|
          begin
            File.delete(key) if key != saved[0]
            @deleted[key] = val if key != saved[0]
            @files.delete(key)
          rescue
            next
          end
        end
     end
  end

  def report
    return "Nothing to report..." unless @deleted.length > 1
    puts "Deleted #{@deleted.length} files, and saved you #{space_reclaimed} of disk space."
  end

  private

    def space_reclaimed
      bytes_deleted = @deleted.values.inject{ |sum, size| sum += size}
      "#{bytes_deleted / (1024.0 * 1024.0)} MiB"
    end

    def files_in dir
      Dir.foreach(dir) {|f| fn = File.join(dir, f); @files[fn] = File.size(fn) if f != '.' && f != '..'}
    end
end



cleaner = Cleaner.new(ARGV[0])
cleaner.clean
cleaner.report
