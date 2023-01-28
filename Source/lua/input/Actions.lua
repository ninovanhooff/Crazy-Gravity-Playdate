Actions = {}

-- Values must be powers of 2 for bit-masking purposes
Actions.None = 0
Actions.Left = 1
Actions.Right = 2
Actions.Throttle = 4
Actions.SelfRight = 8
Actions.SelfDestruct = 16

Actions.Labels = {
    [Actions.Left] = "Left",
    [Actions.Right] = "Right",
    [Actions.Throttle] = "Throttle",
    [Actions.SelfRight] = "Point up",
    [Actions.SelfDestruct] = "Self-destruct",
}
