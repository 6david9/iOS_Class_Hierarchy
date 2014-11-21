require 'find'
require 'set'
require 'json'

if ARGV.count == 0
	puts 'ruby class_hierarchy.rb path_to_project'
	puts "脚本会在执行文件的当前目录下的 Extracted 目录中生成抽取出的类信息，目前只会提取 .h .m .mm 后缀结尾的文件"
	exit -1
end

class Extractor

	attr_reader :class_pairs

	def initialize(path)
		@project_path = path
		@class_pairs = []
		@extensions = %w(.h .m .mm)
	end

	def extract
		@class_pairs = []

		Find.find(@project_path) do |path|
			# 获取文件扩展名
			extname = File.extname(path)

			# 如果是需要解析的文件，则抽取类关系
			grep_class_from_file(path) if @extensions.include?(extname)
		end

		@class_pairs
	end

	private 
	def grep_class_from_file(file_path)
		File.open(file_path) do |f|
			f.each_line do |line|
				# @interface WBTimelineTableViewCell : WBTableViewCell <WBTimelineContentViewDelegate>
				pattern = /@interface\s+(\w+)\s*:\s*(\w+)\s*<?[^@]*$/

				results = line.scan(pattern)
				@class_pairs |= results if results.count > 0
			end
		end
	end
end

class Node

	attr_accessor :name, :parent, :children

	def initialize(name)
		@name = name
		@parent = nil
		@children = Set.new
	end

	def <=>(other)
		if other.name == self.name
			return 0
		end

		return nil
	end

	def ==(other)
		if other.name == self.name
			return true
		end

		return false
	end

	def inspect
		desc = ""
		desc << "{" if @children.length > 0
		desc << %("#{@name}")
		if @children.count > 0
			desc << ":["
			children_arr = @children.to_a
			children_arr.to_a.each_index do |index|
				desc << ',' if index > 0
				desc << children_arr[index].inspect
			end
			desc << "]"
		end
		desc << "}" if @children.length > 0

		return desc
	end

end

class Combiner

	def initialize(class_pairs)
		@class_pairs = class_pairs
		@nodes = {}
		@roots = []
		@roots_str = []
	end

	def generate
		# 创建对象集
		create_node_elements

		# 建立对象间的关系
		bind_relationships

		# 筛选根节点
		filter_root_nodes

		# 遍历根节点，创建继承树
		create_roots_str

		@roots_str
	end

	def each_root_class
		@roots.each do |node|	
			yield node.name, node.inspect
		end
	end

	private
	def create_node_elements
		@nodes = {}

		@class_pairs.each do |pair|
			name = pair[0]
			parent = pair[1]

			@nodes[name] = Node.new(name)
			@nodes[parent] = Node.new(parent)
		end
	end

	def bind_relationships
		@class_pairs.each do |pair|
			node = @nodes[pair[0]]
			parent = @nodes[pair[1]]

			if !parent.nil?
				node.parent = parent
				parent.children << node
			end
		end
	end

	def filter_root_nodes
		@roots = []

		@nodes.each_value do |node|
			@roots << node if node.parent.nil?
		end
	end

	def create_roots_str
		@roots_str = []

		@roots.each do |node|	
			@roots_str << node.inspect
		end
	end
end



project_path = ARGV[0]
base_path = File.dirname(__FILE__)
output_folder_path = File.join(base_path, 'Extracted')



# 抽取类信息,生成一维类信息
extractor = Extractor.new(project_path)
class_pairs = extractor.extract

# 组合类信息，生成继承关系
combiner = Combiner.new(class_pairs)
combiner.generate


# 保存结果到磁盘
system('rm', '-rf', output_folder_path) if Dir.exists? output_folder_path
Dir.mkdir(output_folder_path) 

combiner.each_root_class do |class_name, info|
	output_path = File.join(output_folder_path, "#{class_name}.json")

	File.open(output_path,'w+') do |f|
		obj = JSON.parse(info)
		f.write(JSON.pretty_generate(obj))
	end
end
