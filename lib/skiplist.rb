# Skip lists are relatively new comers to the data structures scene (invented in the 90s).
# They differ from most data structures by being probabilistic rather than deterministic.
# 
# Search, insertion and deletion times are expected to be O(log n) with a very high probability.
#
# Skip lists are normal linked lists with additional layers that enable queries to *skip*
# elements. They are much simpler than other O(log n) structures like Red Black Trees
#
# The skip list supports inserting multiple values for the same key. Values will be stored
# in a list attached to that key. Even a single value will be stored in a list
#
# Keys should implement <=> or you provide your own comparison block to the constructor
#
# The implementation still lacks range searches but they are on the todo list
class SkipList

  class SkipElement
    attr_accessor :key, :values, :levels
    def initialize(key, value)
      @key = key
      @values = [value]
      @levels = []
    end
    def next
    	@levels[0]
    end
  end

  include Enumerable

  attr_reader :length, :levels
  
  # Creates a new skip list, takes an optional parameters 
  # that states how high up the list can go. A block can be
  # supplied which will be used a comparison function 
  def initialize(max_levels = 24, &block)
    @head, @tail = SkipElement.new(nil,nil), SkipElement.new(nil,nil)
  	@max_levels, @levels, @length = max_levels, 1, 0
  	@compare = block || proc{|x,y| x <=> y }
    @tail.levels[0] = nil
    @head.levels[0] = @tail
  end
  
  # Finds element by key, an array will be retrieved containing all
  # the elements in the tree that share that key.
  def [](key)
    return if @length == 0
    record = @head
    (@levels-1).downto(0) do |i|
      record = record.levels[i] while record.levels[i] != @tail and @compare.call(record.levels[i].key, key) < 1         
      return record.values if record.key == key
    end
    nil
  end
  
  # Inserts a new value, if the key exists the new value is appended to its value list otherwise
  # the key is inserted in its correct place and the value becomes the first element to be added
  # it its value list 
  def []=(key, value)
    records, record =  [], @head
    (@levels-1).downto(0) do |i|
      record = record.levels[i] while record.levels[i] != @tail and @compare.call(record.levels[i].key, key) < 1
      records[i] = record
    end
    if record.key == key
       record.values << value
	     @length = @length + 1
	     return value
	  end
    new_record = SkipElement.new(key,value)  
    new_record.levels[0], record.levels[0] = record.levels[0], new_record
	  i = 1
	  while toss
		  if new_record.levels.length > @levels
			  @levels = new_record.levels.length
			  break
		  end
		  new_record.levels[i], records[i].levels[i] = records[i].levels[i], new_record if records[i]
		  @head.levels[i], new_record.levels[i] = new_record, @tail unless records[i]
		  i = i + 1
	  end
	  @length = @length + 1
	  value
  end
  
  # returns the first element on the list as an array of key and value (value is an array as well)
  def shift
    return if @length == 0
    key = @head.next.key
    [key, delete(key)]
  end
      
  def delete(key)
    return if @length == 0
    records, record =  [], @head
    (@levels-1).downto(0) do |i|
      record = record.levels[i] while record.levels[i] != @tail and @compare.call(record.levels[i].key, key) < 0 
      records[i] = record
    end
    record_to_go = record.levels[0]
    return unless record_to_go.key == key
    (records.length-1).downto(0) do |i|
      records[i].levels[i] = record_to_go.levels[i] if records[i].levels[i] == record_to_go
    end    
    @length = @length - record_to_go.values.length
    record_to_go.values
  end
  
  # iterates over all the *values* each key value pair will be returned
  # a key might appear multiple times if there is more than one value associated with it
  def each
	  record = @head
	  while record.next && record.next != @tail
		  record = record.next
		  record.values.each{|value| yield record.key, value }
	  end
  end
  
  # iterates over the keys, a key will be visited once and passed to the block
  def each_key
	  record = @head
	  while record.next && record.next != @tail
		  record = record.next
		  yield record.key
	  end
  end
    
  # iterates over the values passing them to the given block
  def each_value
	  record = @head
	  while record.next && record.next != @tail
		  record = record.next
		  record.values.each{|value| yield value }
	  end
  end

  # returns a list of all keys (no repitions)
  def keys
    list = []
    each_key{|key| list << key}
    list
  end
  
  # returns a list of all values
  def values
    list = []
    each_value{|value| list << value}
    list
  end

  protected
  
  def toss
  	return rand(n=2) > n-2
  end
  
end

if __FILE__ == $0
  def setup
    @arr = [3,2,1,0,4,5,6,5,7,6,8,9]
    @s = SkipList.new
    @arr.each {|e| @s[e] = e }
  end
  test_cases = {
    :test_insert_and_traverse_order => Proc.new do
      print @s.length == @arr.length
      print ' '
      arr = []
      @s.each do |key,value|
        arr << value
      end
      print arr == @arr.sort
      print ' '
      arr = []
      @s.each_key do |key|
        arr << key
      end
      print arr == @arr.uniq.sort
      print ' '
            
    end,
    :test_delete => Proc.new do
      @s.delete(130)
      print @s.length == @arr.length 
      print ' '
      @s.delete(3)
      print @s.length == @arr.length - 1
      print ' '
      print @s.keys == [2,1,0,4,5,6,5,7,6,8,9].uniq.sort
      print ' '
      print @s.values == [2,1,0,4,5,6,5,7,6,8,9].sort
      print ' '
      @s.delete(5)
      print @s.length == @arr.length - 3
      print ' '
      print @s.keys == [2,1,0,4,6,7,6,8,9].uniq.sort
      print ' '
      print @s.values == [2,1,0,4,6,7,6,8,9].sort
      print ' '
    end,
    :test_shift => Proc.new do
      arr = []
      arr2 = []
      while rec = @s.shift
        arr << rec[0]
        arr2 << rec[1]
      end
      print arr.flatten == @arr.uniq.sort
      print ' '
      print arr2.flatten == @arr.sort
      print ' '
      print @s.length == 0
      print ' '
    end
  }
  test_cases.each do |name, block|
    print name.to_s.gsub('_',' ') + ': '
    setup
    block[]
    puts;puts
  end  
end
