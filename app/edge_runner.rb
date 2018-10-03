class EdgeRunner < SKSpriteNode
 	attr_accessor :bounds_size
 	attr_accessor :side
	
	def initWithTexture(texture, bounds_size)
		super
		@bounds_size = bounds_size
		width_end = @bounds_size.width/2
		height_end = @bounds_size.height/2
		@tip_value = {
			:leftx => -width_end,
			:rightx => width_end,
			:topy => height_end,
			:bottomy => -height_end
			}
		@ranges = {
			:range_x => SKRange.rangeWithLowerLimit(-(width_end), upperLimit: width_end),
			:constant_x_right => SKRange.rangeWithConstantValue(width_end + 10),
			:constant_x_left => SKRange.rangeWithConstantValue(-(width_end + 10)),
			:range_y => SKRange.rangeWithLowerLimit(-(height_end), upperLimit: height_end),
			:constant_y_top => SKRange.rangeWithConstantValue(height_end + 10),
			:constant_y_bottom => SKRange.rangeWithConstantValue(-(height_end + 10))
			}
		# Don't name this @constraints bc super SKSpriteNode#constraints.
		@limits = {
			:top => [SKConstraint.positionX(@ranges[:range_x]), 
				SKConstraint.positionY(@ranges[:constant_y_top])],
			:bottom => [SKConstraint.positionX(@ranges[:range_x]), 
				SKConstraint.positionY(@ranges[:constant_y_bottom])],
			:right => [SKConstraint.positionX(@ranges[:constant_x_right]), 
				SKConstraint.positionY(@ranges[:range_y])],
			:left => [SKConstraint.positionX(@ranges[:constant_x_left]), 
				SKConstraint.positionY(@ranges[:range_y])]
			}
		self
	end
	
	def self.edgeRunnerWithImage(image, bounds_size)
		texture = SKTexture.textureWithImageNamed(image)
		sprite = EdgeRunner.alloc.initWithTexture(texture, bounds_size)
		sprite.name = "Edge_runner"
		sprite.position = CGPointMake(0, bounds_size.height/2 + 10)
		sprite.set_side(:top)
  	sprite
	end
	
	def nose_position
		nose = self.position
		case @side
		when :top then nose.y -= 16
		when :bottom then nose.y += 16
		when :left then nose.x += 16
		when :right then nose.x -= 16
		end	
		nose
	end
		
	def tip(location)
		prev_side = @side
		case @side
		when :top, :bottom
			set_side(:left) if location.x < @tip_value[:leftx] #position.x
			set_side(:right) if location.x > @tip_value[:rightx] #position.x				
		when :left, :right
			set_side(:bottom) if location.y < @tip_value[:bottomy] #position.y
			set_side(:top) if location.y > @tip_value[:topy] #position.y
		end
		# Return true if changed side.
		prev_side != @side
	end
	
	def center_position
		case @side
		when :top then self.position = CGPointMake(0, @bounds_size.height/2 + 10)
		when :bottom then self.position = CGPointMake(0, -(@bounds_size.height/2 + 10))
		when :left then self.position = CGPointMake(-(@bounds_size.width/2 + 10), 0)
		when :right then self.position = CGPointMake(@bounds_size.width/2 + 10, 0)
		end		
	end
	
	def set_side(side)
		@side = side
		case @side
		when :top 
			self.constraints = @limits[:top]
			self.zRotation = Handy.degrees_to_radians(0)
		when :bottom 
			self.constraints = @limits[:bottom]
			self.zRotation = Handy.degrees_to_radians(180)
		when :left 
			self.constraints = @limits[:left]
			self.zRotation = Handy.degrees_to_radians(90)
		when :right 
			self.constraints = @limits[:right]
			self.zRotation = Handy.degrees_to_radians(270)
		end		
	end
	
end