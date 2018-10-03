class EdgeRunnerScene < Scene #SKScene
	def initWithSize(size)
		super
		
		self.name = "Edge_runner_scene"
		self.backgroundColor = UIColor.redColor
    
		self
	end

	def didMoveToView(view)
		super

		add_bounds(view)
		
		dash_layer_height = @bounds_size.height-4
		@dash_layer = SKSpriteNode.spriteNodeWithColor(self.backgroundColor,
			size: CGSizeMake(2.0, dash_layer_height))
		@dash_layer.name = "Dash_layer"
		@dash_layer.position = CGPointMake(-@bounds_size.width/2, 0)
		@dash_layer.hidden = true
		
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

		@active_sprite = nil		
	end

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

	def on_hot_bottomright
			self.view.window.rootViewController.go_to_scene(:tally_scene)
	end

	def touchesBegan(touches, withEvent: _)
		return if hot_corner(touches, self)
			
		@had_touches_moved = false
		touch = touches.allObjects.first	
		location = touch.locationInNode(self)
		node = nodeAtPoint(location)
		case node.name
		when "Marker"			
			@active_sprite = node 
		end		
	end
	
	def touchesMoved(touches, withEvent: _)
		@had_touches_moved = true
		
		return unless @active_sprite
		
		touch = touches.allObjects.first
		if @active_sprite == @marker
			# note position -- @marker has no phys body, set position
			@marker.position = touch.locationInNode(self) 
			if @marker.tip(touch.locationInNode(@active_sprite.parent))
				shift_gravity
			end
		end
	end
	
	def touchesCancelled(touches, withEvent: _)
		@active_sprite = nil
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
			end		
		end
		@active_sprite = nil
	end
	
end