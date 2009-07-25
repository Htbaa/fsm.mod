SuperStrict

Rem
	bbdoc: htbaapub.fsm
EndRem
Module htbaapub.fsm
ModuleInfo "Name: htbaapub.fsm"
ModuleInfo "Version: 1.0"
ModuleInfo "Author: Christiaan Kras"
ModuleInfo "Git repository: <a href='http://github.com/Htbaa/htbaapub.mod/'>http://github.com/Htbaa/htbaapub.mod/</a>"

Import brl.linkedlist

Rem
	bbdoc: Default FSM State type
End Rem
Const FSM_STATE_NONE:Int = 0

Rem
	bbdoc: Default FSM Machine type
End Rem
Const FSM_MACH_NONE:Int = 0

Rem
	bbdoc: Finite Machine State Type
End Rem
Type TFSMState Abstract
	Field m_type:Int
	Field m_parent:Object
	
	Rem
		bbdoc: Method executed when this state is entered
	End Rem
	Method Enter()
	End Method
	
	Rem
		bbdoc: Main loop of state
		about: Optionally assign the amount of time passed to t:Double. This is usually wanted with delta timing.
	End Rem
	Method Update(t:Double = 0)
	End Method
	
	Rem
		bbdoc: Method to execute when the State Machine is being setup
	End Rem	
	Method Init()
	End Method
	
	Rem
		bbdoc: Check for transitions
	End Rem	
	Method CheckTransitions:Int() 
		Return FSM_STATE_NONE
	End Method	
	
	Rem
		bbdoc: Method to execute when leaving this state
	End Rem	
	Method Quit() 
	End Method
	
	Rem
		bbdoc: Freeing of state
	End Rem
	Method Free()
		Self.m_parent = Null
	End Method
	
	Rem
		bbdoc: Handle an incoming message
	End Rem	
	Method OnMessage:Int(message:Object)
		Return False
	End Method
End Type

	
Rem
	bbdoc: Finite Machine Type
End Rem
Type TFSMMachine Extends TFSMState

	Field m_type:Int
	'Private data members
	Field m_states:TList = New TList
	Field m_currentState:TFSMState
	Field m_defaultState:TFSMState
	Field m_goalState:TFSMState
	Field m_goalID:Int
	
	
	Rem
		bbdoc: Create A Finite State Machine
	End Rem
	Method Create:TFSMMachine(state_type:Int = FSM_MACH_NONE, parent:Object)
		Self.m_type = state_type
		Self.m_parent = parent
		Self.m_currentState = Null
		Self.m_defaultState = Null
		Self.m_goalState = Null
		Return Self
	End Method
	
	Rem
		bbdoc: Create A Finite State Machine * DEPRECATED *
		about: This function has been deprecated. Use the method Create() instead.
	End Rem
	Function CreateMachine:TFSMMachine(state_type:Int = FSM_MACH_NONE, parent:Object) Final
		Return New TFSMMachine.Create(state_type, parent)
	End Function
	
	Rem
		bbdoc: Handle incoming messages
	End Rem
	Method HandleMessage:Int(message:Object)
		If Not Self.m_currentState
			Return False
		End If
		
		Return Self.m_currentState.OnMessage(message)
	End Method

	Rem
		bbdoc: Update State Machine. Handles state changeing and execution
	End Rem
	Method UpdateMachine(t:Double)
		'Don't do anything if you have no states
		If Self.m_states.Count() = 0
			Return
		End If

		'Don't do anything if there's no current
		'state, and no default state
		If Not Self.m_currentState
			Self.m_currentState = m_defaultState
		End If
		
		If Not Self.m_currentState
			Return
		End If
		
		'Check for transitions and then update
		Local oldStateID:Int = Self.m_currentState.m_type
		Self.m_goalID = Self.m_currentState.CheckTransitions() 

		'Switch if there was a transition
		If Self.m_goalID <> oldStateID
		'If Not (Self.m_goalID=oldStateID)
			If Self.TransitionState(Self.m_goalID)
				Self.m_currentState.Quit()
				Self.m_currentState = Self.m_goalState
				Self.m_currentState.Enter()
			End If
		End If

		Self.m_currentState.Update(t) 
	End Method
		
	Rem
		bbdoc: Add a state to machine
	End Rem
	Method AddState(state:TFSMState) 
		Self.m_states.AddLast(state)
	End Method
		
	Rem
		bbdoc: Set default state
	End Rem
	Method SetDefaultState(state:TFSMState)
		Self.m_defaultState = state
	End Method
		
	Rem
		bbdoc: Set goal id
	End Rem
	Method SetGoalId(goal:Int)
		Self.m_goalID = goal
	End Method
		
	Rem
		bbdoc: Change state
	End Rem
	Method TransitionState:Int(goal:Int)
		'Don't do anything if you have no states
		If Self.m_states.Count() = 0
			Return False
		End If
		
		'Determine if we have state of type 'goal'
		'in the list, and switch to it, otherwise, quit out
		For Local state:TFSMState = EachIn Self.m_states
			If state.m_type = goal
				Self.m_goalState = state
				Return True
			End If
		Next
		Return False
	End Method
		
	Rem
		bbdoc: Reset the state machine
	End Rem
	Method Reset() 
		Self.Quit() 
		If Self.m_currentState
			Self.m_currentState.Quit()
		End If
		
		Self.m_currentState = Self.m_defaultState;
		
		'Init all the states
		For Local state:TFSMState = EachIn Self.m_states
			state.Init()
		Next
		
		'And now enter the m_defaultState, if any
		If Self.m_currentState
			Self.m_currentState.Enter()
		End If
	End Method
		
	Rem
		bbdoc: Free state machine
	End Rem
	Method Free()
		Self.m_currentState = Null
		Self.m_defaultState = Null
		Self.m_goalState = Null		
	
		'Free every state
		For Local state:TFSMState = EachIn Self.m_states
			state.Free()
		Next

		'Remove all the states
		Self.m_states.Clear()
		'Remove parent
		Self.m_parent = Null
	End Method
End Type
