class Array
	def natural_join(joint_str)
		case count
		when 0
			return ""
		when 1
			return first.to_s
		else
			first(count - 1).join(", ") + " #{joint_str} #{last}"
		end
	end

	alias_method :to_s_orig, :to_s

	def to_s
		natural_join("and")
	end

	def or_join
		natural_join("or")
	end

	def show
		'[' + join(', ') + ']'
	end
end