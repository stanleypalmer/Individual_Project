import gymnasium as gym
import numpy as np
import dedalus.public as d3
import matplotlib.pyplot as plt
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import SubprocVecEnv
from stable_baselines3.common.env_util import make_vec_env
from rbc_env import DedalusRBC_Env
#env = make_vec_env(DedalusRBC_Env, n_envs=30, seed=0, vec_env_cls=SubprocVecEnv)
gym.envs.register(id='rbc', entry_point=DedalusRBC_Env)
env = gym.make('rbc', render_mode="human")
model = PPO.load("trainedmodels/Ra1e6_30envs_5e5steps", env=env)
#Wrapping the env with a `Monitor` wrapper
#Wrapping the env in a DummyVecEnv.
from stable_baselines3.common.evaluation import evaluate_policy
mean_reward, std_reward = evaluate_policy(model, model.get_env(), n_eval_episodes=3)
vec_env = model.get_env()
obs = vec_env.reset()
for i in range(256):
    action, _ = model.predict(obs, deterministic=True)
    obs, _, _, _ = vec_env.step(action)
    T = env.unwrapped.problem.variables[1]['g']
    fig, ax = plt.subplots()
    c = ax.imshow(np.transpose(T), aspect=1/np.pi, origin="lower", vmin=0., vmax=1.4)
    fig.colorbar(c)
    plt.title('$Nu=$'+str(np.round(env.unwrapped.fp.properties['Nu']['g'].flatten()[-1], 2)))
    plt.savefig('images5_Ra1e6_30envs_5e5steps/'+str(i)+'.png')
    plt.close()
env.unwrapped.solver.stop_sim_time *= 2
for i in range(256):
    action, _ = model.predict(obs)
    obs, _, _, _ = vec_env.step(action*0)
    T = env.unwrapped.problem.variables[1]['g']
    fig, ax = plt.subplots()
    c = ax.imshow(np.transpose(T), aspect=1/np.pi, origin="lower", vmin=0., vmax=1.4)
    fig.colorbar(c)
    plt.title('$Nu=$'+str(np.round(env.unwrapped.fp.properties['Nu']['g'].flatten()[-1], 2)))
    plt.savefig('images4_Ra1e6_30envs_5e5steps/'+str(248+i)+'.png')
    plt.close()
model.predict(obs)
 

r = DedalusRBC_Env()
r.reset()

r.solver.dist.local_grid()