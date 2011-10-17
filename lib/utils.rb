require 'lib/process'

module Utils
  def round_up(n, d)
    n += d
    n -= n % d
    n
  end

  def round_down(n, d)
    round_up(n, d) - d
  end

  def dev_size(dev_or_path)
    ProcessControl.system("102400", "blockdev --getsize #{dev_or_path}").chomp.to_i
  end

  def wipe_device(dev_or_path, sectors = nil)
    size = dev_size(dev_or_path)

    if sectors.nil? || size < sectors
      sectors = size
    end

    block_size = 2048 * 64       # 64 M
    count = sectors / block_size
    if count > 0
      ProcessControl.run("dd if=/dev/zero of=#{dev_or_path} oflag=direct bs=#{block_size * 512} count=#{count}")
    end

    remainder = sectors % block_size
    if remainder > 0
      # we have a little bit to do at the end
      offset = count * block_size
      ProcessControl.run("dd if=/dev/zero of=#{dev_or_path} oflag=direct bs=#{remainder * 512} count=1 seek=#{offset * 512}")
    end
  end

  def dt_device(file, io_type = nil, pattern = nil, size = nil)
    iotype = io_type.nil? ? "random" : "sequential"
    if pattern.nil?
      pattern = "iot"
    end
    if size.nil?
       size = dev_size(file)
    end

    ProcessControl.run("dt of=#{file} capacity=#{size*512} pattern=#{pattern} passes=1 iotype=#{iotype} bs=4M")
  end

  def get_dev_code(path)
    stat = File.stat(path)
    if stat.blockdev?
      "#{stat.rdev_major}:#{stat.rdev_minor}"
    else
      path
    end
  end

  def Utils.retry_if_fails(duration)
    begin
      yield
    rescue Exception
      ProcessControl.sleep(duration)
      yield
    end
  end
end

