Gem::Specification.new do |s|
  s.name     = "skiplist"
  s.version  = "0.2"
  s.date     = "2009-04-11"
  s.summary  = "A sorted data structure implementation for Ruby"
  s.email    = "oldmoe@gmail.com"
  s.homepage = "http://github.com/oldmoe/skiplist"
  s.description = "A skip list is a sorted linked list with randomly generated shortcut lists that allow O(log n) operations with high probability"
  s.has_rdoc = true
  s.authors  = ["Muhammad A. Ali"]
  s.platform = Gem::Platform::RUBY
  s.files    = [ 
		"skiplist.gemspec", 
		"README",
		"lib/skiplist.rb"
	]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end

