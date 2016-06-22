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

	def to_s
		natural_join("and")
	end

	def or
		natural_join("or")
	end
end