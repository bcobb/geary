module Geary
  class CLI

    def initialize(argv, n=STDIN, o=STDOUT, e=STDERR, k=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, n, o, e, k
    end

    def execute!
      @kernel.exit(0)
    end

  end
end
