class DragWithPhysicsScene < Scene #SKScene
	def initWithSize(size)
		super
		
		self.name = "Drag_with_physics_scene"
		self.backgroundColor = UIColor.orangeColor
    
		self
	end

	def didMoveToView(view)
		super

		# @touch_shadow is a tiny sprite that will position itself at the
		# touch point whenever a drag is happening, so we can have another
		# sprite track and orient itself to it. Add this first so it's zPosition
		# is lowest and won't obscure other sprites. 
		@touch_shadow = SKSpriteNode.spriteNodeWithColor(self.backgroundColor,
			size: CGSizeMake(1, 1))
		@touch_shadow.name = "Touch_shadow"
		addChild(@touch_shadow)
		
		add_bounds(view)
		
		@purple = SKSpriteNode.spriteNodeWithImageNamed("purpleball.png")
		@purple.position = CGPointMake(-50, -(@bounds_size.height/2 + 40))
		@purple.name = "Purple"

 		@purple.physicsBody = SKPhysicsBody.bodyWithCircleOfRadius(27)
		@purple.physicsBody.dynamic = false # default is true
 		@purple.physicsBody.affectedByGravity = false
 		@purple.physicsBody.allowsRotation = false # can't see it on circle anyway!!!

		@purple.physicsBody.categoryBitMask = @obstacle_catmask
		@purple.physicsBody.collisionBitMask = @obstacle_collision
		@purple.physicsBody.contactTestBitMask = @ball_catmask

		@rect = SKSpriteNode.spriteNodeWithImageNamed("redrectwide.png")
		@rect.position = CGPointMake(50, -(@bounds_size.height/2 + 40))
		@rect.name = "Rect"

		@rect_follow_touch = [SKConstraint.orientToNode(@touch_shadow,
			offset: SKRange.rangeWithConstantValue(-Math::PI / 2))]
		addChild(@purple)

 		@rect.physicsBody = SKPhysicsBody.bodyWithRectangleOfSize(CGSizeMake(55, 42))
		@rect.physicsBody.dynamic = false # default is true
 		@rect.physicsBody.affectedByGravity = false
 		# let it spin when it hits @purple, just to see
 		@rect.physicsBody.allowsRotation = true # default is true
		@rect.physicsBody.categoryBitMask = @obstacle_catmask
		@rect.physicsBody.collisionBitMask = @obstacle_collision 		
		addChild(@rect)
	
		@active_sprite = nil
    @active_scruff = nil # the point within @active_sprite we're dragging by
    @active_location = nil # prev position of @active_sprite		
	end

	def on_hot_bottomleft
			self.view.window.rootViewController.go_to_scene(:tally_scene)
	end

	def touchesBegan(touches, withEvent: _)
		return if hot_corner(touches, self)
			
		@had_touches_moved = false
		
		touch = touches.allObjects.first
		location = touch.locationInNode(self)
		node = nodeAtPoint(location)
		
		@touch_shadow.position = location

		case node.name
		when "Purple", "Rect"
			# need to make it dynamic while we drag or it won't move
			node.physicsBody.dynamic = true 
			@active_sprite = node
			@active_scruff = touch.locationInNode(node)
			@active_location = location
		end
	end
	
	def touchesMoved(touches, withEvent: _)
		@had_touches_moved = true # we're dragging, sprite or just touch
		
		touch = touches.allObjects.first
		location = touch.locationInNode(self)

		@touch_shadow.position = location
		@active_location = location

		# if we touched anywhere but @rect, have @rect follow our @touch_shadow
		@rect.constraints = @rect_follow_touch unless @active_sprite == @rect
	end
	
	def touchesCancelled(touches, withEvent: _)
		@active_sprite.physicsBody.dynamic = false if @active_sprite
		@active_location = nil
		@active_scruff = nil
		@active_sprite = nil
		@rect.constraints = []
	end

	def touchesEnded(touches, withEvent: _)
		touch = touches.allObjects.first
		location = touch.locationInNode(self)
		node = nodeAtPoint(location)
		
		if !@had_touches_moved
			case node.name
			when "Ball"
				node.removeFromParent
			when "Bounds"
				add_ball(location)
			end
		end

		touchesCancelled(touches, withEvent: nil)
	end

	
	def update(current_time)
		# Why 20? No idea, copied it off the net. Works for now. FIXME!!!
		if @active_sprite && @active_location && @active_scruff
			vector = CGVectorMake(
				(@active_location.x - @active_sprite.position.x - @active_scruff.x) * 20, 
				(@active_location.y - @active_sprite.position.y - @active_scruff.y) * 20)
			@active_sprite.physicsBody.velocity = vector
		end
	end
	

end
