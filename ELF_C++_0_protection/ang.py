import angr
import sys

def main(argv):
    path = argv[1]
    project = angr.Project(path)
    init = project.factory.entry_state()
    simulation = project.factory.simgr(init)

    def success(state):
        return b"Congratz. You can validate with this password..." in state.posix.dumps(sys.stdout.fileno())

    def should_abort(state):
        return b"Password incorrect." in state.posix.dumps(sys.stdout.fileno())
    
    simulation.explore(find=success, avoid=should_abort)

    if simulation.found:
        sol_state = simulation.found[0]
        print('pass: ', sol_state.posix.dumps(sys.stdin.fileno))
    else:
        raise Exception('Could not find the solution')

if __name__ == "__main__":
    main(sys.argv)