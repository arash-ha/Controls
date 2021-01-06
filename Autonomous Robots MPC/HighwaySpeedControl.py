import numpy as np
from sim.sim1d import sim_run

# Simulator options.
options = {}
options['FIG_SIZE'] = [8,8]
options['FULL_RECALCULATE'] = False

class ModelPredictiveControl:
    def __init__(self):
        self.horizon = 20
        self.dt = 0.2

        # Reference or set point the controller will achieve.
        self.reference = [50, 0, 0]

    def plant_model(self, prev_state, dt, pedal, steering):
        x_t = prev_state[0]
        v_t = prev_state[3] # m/s
        x_t += v_t * dt
        v_t += pedal * dt - v_t/25.0
        return [x_t, 0, 0, v_t]

    def cost_function(self, u, *args):
        cost = 0.0
        state = args[0]
        ref = args[1]
        for i in range(self.horizon):
            v = state[3]
            state = self.plant_model(state, self.dt, u[i * 2], u[i * 2 + 1])
            if state[0] != ref[0]:
                cost += (ref[0] - state[0]) ** 2 + ((v * 3600) if ((v * 3.6) > 10.0) else 0)
        return cost

sim_run(options, ModelPredictiveControl)
