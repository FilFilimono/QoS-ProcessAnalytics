import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('scaling.csv')

plt.figure(figsize=(10, 6))


plt.plot(df['time_e'], df['i'], 'b-o', label='E-core Cluster', linewidth=2)
plt.plot(df['time_p'], df['i'], 'r-s', label='P-core Cluster', linewidth=2)

plt.xlabel('Время выполнения (ms)', fontsize=12)
plt.ylabel('Количество итераций (i)', fontsize=12)
plt.title('Анализ масштабируемости ядер M3: Время vs Сложность', fontsize=14)

plt.grid(True, which='both', linestyle='--', alpha=0.5)
plt.legend()


for i in range(len(df)):
    plt.annotate(f"{int(df['time_e'][i])}ms", (df['time_e'][i], df['i'][i]), textcoords="offset points", xytext=(-10,5), ha='right', color='blue')
    plt.annotate(f"{int(df['time_p'][i])}ms", (df['time_p'][i], df['i'][i]), textcoords="offset points", xytext=(10,5), ha='left', color='red')

plt.tight_layout()
plt.savefig('final_plot.png')
plt.show()