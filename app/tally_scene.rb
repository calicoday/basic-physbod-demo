class TallyScene < Scene #SKScene
	def initWithSize(size)
		super
		
		self.name = "Tally_scene"
		self.backgroundColor = UIColor.whiteColor
    
		self
	end

	def didMoveToView(view)
		super
		self.backgroundColor = UIColor.whiteColor

		# Add touch_shadow from DragWithPhysicsScene.
		@touch_shadow = SKSpriteNode.spriteNodeWithColor(self.backgroundColor,
			size: CGSizeMake(1, 1))
		@touch_shadow.name = "Touch_shadow"
		addChild(@touch_shadow)
		
		# Shared but not in superclass so we can choose the order it's added.
		add_bounds(view)
		
		# Add purple and rect from DragWithPhysicsScene.
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

		dash_layer_height = @bounds_size.height-4
		@dash_layer = SKSpriteNode.spriteNodeWithColor(self.backgroundColor,
			size: CGSizeMake(2.0, dash_layer_height))
		@dash_layer.name = "Dash_layer"
		@dash_layer.position = CGPointMake(-@bounds_size.width/2, 0)
		@dash_layer.hidden = true
		
		# Add dash_layer, marker and hole from EdgeRunnerScene.
		dash_length = 10
		dash_size = CGSizeMake(2.0, dash_length)
		y = 0
		begin
			y += dash_length
			dash = SKShapeNode.shapeNodeWithRectOfSize(dash_size)
			dash.name = "Dash"
			dash.position = CGPointMake(0, y - @bounds_size.height/2)
			dash.fillColor = UIColor.greenColor
			@dash_layer.addChild(dash)
			y += dash_length
		end while y < dash_layer_height
		addChild(@dash_layer)

		@marker = EdgeRunner.edgeRunnerWithImage("yellowstardown.png", @bounds_size)
		@marker.name = "Marker"
		@marker.set_side(:top)
		@marker.center_position		
		addChild(@marker)
		
		@hole = SKSpriteNode.spriteNodeWithImageNamed("hole.png")
		@hole.position = CGPointMake(-50, -170)
		@hole.xScale = 0.75
		@hole.yScale = 0.75

		# the ball has to overlap a good bit of the hole, not just contact the edge, to fall
		@hole.physicsBody = SKPhysicsBody.bodyWithCircleOfRadius((27/2) * @hole.xScale)
		@hole.physicsBody.dynamic = false
		
		@hole.physicsBody.categoryBitMask = @hole_catmask
		@hole.physicsBody.contactTestBitMask = @ball_catmask		
		addChild(@hole)

		# Shared
		@active_sprite = nil		
	
		# Add from DragWithPhysicsScene
		@active_sprite = nil
    @active_scruff = nil # the point within @active_sprite we're dragging by
    @active_location = nil # prev position of @active_sprite		
	end

	# Add shift gravity and hole contact methods from EdgeRunnerScene.
	def shift_gravity
		@dash_layer.hidden = true
		@bounds.physicsBody.categoryBitMask = @edge_catmask 
		case @marker.side
		when :top 
			self.physicsWorld.gravity=CGVectorMake(0, -@pull_value)
		when :left
			self.physicsWorld.gravity=CGVectorMake(@pull_value, 0)
		when :bottom
			self.physicsWorld.gravity=CGVectorMake(0, @pull_value)
		when :right
			self.physicsWorld.gravity=CGVectorMake(-@pull_value, 0)
			@bounds.physicsBody.categoryBitMask = @leaky_catmask 
			@dash_layer.hidden = false
		end
	end

	def didBeginContact(contact)
		ball = nil
		if (contact.bodyA.node == @hole && contact.bodyB.node.name == "Ball")
			ball = contact.bodyB.node
		elsif (contact.bodyB.node == @hole && contact.bodyA.node.name == "Ball")
			ball = contact.bodyA.node
		end
		return if !ball
		
		vector = CGVectorMake((@hole.position.x - ball.position.x) * 200, 
			(@hole.position.y - ball.position.y) * 200)
		ball.physicsBody.velocity = vector
		ball.removeFromParent			
	end

	# TallyScene specific...
	def on_hot_bottomleft
			self.view.window.rootViewController.go_to_scene(:edge_scene)
	end

	def on_hot_bottomright
			self.view.window.rootViewController.go_to_scene(:drag_scene)
	end

	# Blended touch handling
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
		when "Marker"			
			@active_sprite = node 
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

		return unless @active_sprite
		
		touch = touches.allObjects.first
		if @active_sprite == @marker  # or test on name???
			# note position -- @marker has no phys body, set position
			@marker.position = touch.locationInNode(self) 
			if @marker.tip(touch.locationInNode(@active_sprite.parent))
				shift_gravity
			end
		end
	end

	def touchesCancelled(touches, withEvent: _)
		if @active_sprite && @active_sprite.physicsBody
			@active_sprite.physicsBody.dynamic = false 
		end
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
			when "Marker"			
				add_ball(@marker.nose_position)
			#when "Bounds" #nope
			#	add_ball(location)
			end
		end

		touchesCancelled(touches, withEvent: nil)
	end

	def update(current_time)
		if @active_sprite && @active_location && @active_scruff
			vector = CGVectorMake(
				(@active_location.x - @active_sprite.position.x - @active_scruff.x) * 20, 
				(@active_location.y - @active_sprite.position.y - @active_scruff.y) * 20)
			@active_sprite.physicsBody.velocity = vector
		end
	end
end
