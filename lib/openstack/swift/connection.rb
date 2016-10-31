module OpenStack
  module Swift
    class ChunkedConnectionWrapper
      def read(length, out_str)
        s = @file.read(length)
        if s.nil?
          return nil
        end
        out_str << s
        s
      end
    end
  end
end
