Import htbaapub.fsm

Const MACH_GAME:Int = 1
Const STATE_PLAY:Int = 1
Const STATE_GAMEOVER:Int = 2

Graphics(640, 480)

'Create a new FSM - This one for example could hold all your games' states. Like TitleScreen, Play, Credits, HighScores
'MACH_GAME is just a Const Int. Assign different identifiers to your machines to keep them apart.
Local machine:TFSMMachine = New TFSMMachine.Create(MACH_GAME, Null)
Local statePlay:TStatePlay = New TStatePlay
'Add the state to the machine
machine.AddState(statePlay)
'And make it default
machine.SetDefaultState(statePlay)
'Add TStateGameOver to the machine
machine.AddState(New TStateGameOver)

'Call reset so all states get properly initialized
machine.Reset()
Repeat
	'As this FSM represents our main game loop delta timing is not need
	'If never needed at all just pass 0
	machine.UpdateMachine(0)
Until AppTerminate()

'Free all states, clean up references, unload stuff etc.
machine.Free()

Rem
	bbdoc: A state that represents the Play mode of your game
End Rem
Type TStatePlay Extends TFSMState	
	Rem
		bbdoc:Method to execute when the State Machine is being setup
	End Rem
	Method Init()
		Self.m_type = STATE_PLAY
		DebugLog "State TStatePlay Initialized"
	End Method

	Rem
		bbdoc:Method executed when this state is entered
	End Rem
	Method Enter()
		DebugLog "TStatePlay entered"
	End Method

	Rem
		bbdoc:Method to execute when leaving this state
	End Rem
	Method Quit()
		DebugLog "TStatePlay quited"
	End Method

	Rem
		bbdoc:Update state
	End Rem
	Method Update(t:Double = 0)
		Cls
		DrawText("TStatePlay", 0, 0)
		Flip
	End Method

	Rem
		bbdoc:Logic to check if we need to make a transition to another state
	End Rem
	Method CheckTransitions:Int()
		'It's probably not a good idea to check for input here
		'but it's for the sake of simplicity
		If KeyHit(KEY_SPACE)
			Return STATE_GAMEOVER
		End If
		'If no transition needs to be made stick with our current state
		Return STATE_PLAY
	End Method
	
	Rem
		bbdoc:Freeing of state
	End Rem
	Method Free()
		DebugLog "TStatePlay freed"
	End Method
End Type

Rem
	bbdoc:
End Rem
Type TStateGameOver Extends TFSMState
	Rem
		bbdoc:Method to execute when the State Machine is being setup
	End Rem
	Method Init()
		Self.m_type = STATE_GAMEOVER
		DebugLog "State TStateGameOver Initialized"
	End Method

	Rem
		bbdoc:Method executed when this state is entered
	End Rem
	Method Enter()
		DebugLog "TStateGameOver entered"
	End Method

	Rem
		bbdoc:Method to execute when leaving this state
	End Rem
	Method Quit()
		DebugLog "TStateGameOver quited"
	End Method

	Rem
		bbdoc:Update state
	End Rem
	Method Update(t:Double = 0)
		Cls
		DrawText("TStateGameOver", 0, 0)
		Flip
	End Method

	Rem
		bbdoc:Logic to check if we need to make a transition to another state
	End Rem
	Method CheckTransitions:Int()
		'It's probably not a good idea to check for input here
		'but it's for the sake of simplicity
		If KeyHit(KEY_SPACE)
			Return STATE_PLAY
		End If
		'If no transition needs to be made stick with our current state
		Return STATE_GAMEOVER
	End Method
	
	Rem
		bbdoc:Freeing of state
	End Rem
	Method Free()
		DebugLog "TStateGameOver freed"
	End Method
End Type