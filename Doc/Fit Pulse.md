# Fit Pulse 9615N

Esta documentación define la funcionalidad del dispositivo Fit Pulse 9615N.

## Funcionalidades

### Actividad

El dispositivo registra la actividad de pasos, calorias y distancia recorrida.

### Sueño

Si el modo sueño automático está activado el dispositivo entrará en modo sueño y guardará registros de los movimientos realizados.

Los registros de sueño se dividen dependiendo del tipo de sueño:
* 1: Enter sleep
* 2: Wakeup
* 3: Deep sleep
* 4: Shallow sleep
* 5: No wear

### Cardio

El dispositivo registra datos de cardio cada minuto y los devuelve en bloques de horas.

### Deportes

Desde el dispositivo se puede iniciar una actividad de deporte las cuales pueden tener los valores de pasos, calorias, distancia o repeticiones dependiendo del deporte que sea.

Se pueden asignar 5 deportes, el primero siempre ha de ser el id 1 walk.

Listado de deportes:
* 1: walk
* 2: sit-up
* 3: push-up
* 4: rope-skipping
* 5: mountainneering
* 6: pull-up
* 128: badminton
* 129: basketball
* 130: football
* 131: swim
* 132: volleyball
* 133: table-tennis
* 134: bowling
* 135: tennis
* 136: cycling
* 137: ski
* 138: skate
* 139: rock-climbing
* 140: gym
* 141: dance
* 142: tablet-support
* 143: gym-exercise
* 144: yoga
* 145: shuttlecock

### Notificaciones

Se pueden mandar textos al dispositivo que mostrará como notificaciones.

### Alarma

Se pueden asignar un maximo de 7 alarmas en el dispositivo.

En una alarma se pueden definir los dias de semana en los que sonará, si se repetirá, a hora y el minuto en el que sonará.

### Calendario

Se pueden asignar eventos en el calendario del dispositivo.

Los eventos constan de una fecha, un titulo y un texto.

### Aviso sedentario

Se pueden asignar avisos sedentarios en el dispositivo, estos avisos sedentarios constan de una hora de inicio, una hora de fin, un objetivo de movimientos y un espacio de tiempo.

Si entre la hora de inicio y la hora de fin en el espacio de tiempo definido no se producen los movimientos asignados, el dispositivo notificará que el objetivo no se ha alcanzado.
