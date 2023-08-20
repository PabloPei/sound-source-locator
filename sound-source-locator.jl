### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ ce0cbc70-cab3-11eb-0306-67a77845ad26
using SyS

# ╔═╡ 3d288dd5-f787-499d-a2d6-d1397f9648c6
using SampledSignals

# ╔═╡ c05a56df-73e6-4173-bd30-07891e168186
TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)


# ╔═╡ d8812310-d724-411a-9a4a-e93e851dcb42
md"""
$(LocalResource(joinpath("resources", "img", "FIUBA.png"))) 

# Trabajo Práctico: Procesamiento de señales de un arreglo de micrófonos

**Nombre: Pablo Peiretti** 

**Padron: 103592**

**Primer Cuatrimestre 2021**


 
"""

# ╔═╡ 36abb369-5bf7-4c46-bc74-9e963c4d4fd1
md"""
## Introducción
"""

# ╔═╡ 8573c36c-fd93-4618-9ca9-abcc3cbe21c6
md"""
La localización de una fuente sonora es de interés en muchas aplicaciones, por ejemplo: un robot puede
descubrir la posición de la persona que le esté hablando; detectar fuentes de ruido para su posterior filtrado;
sistemas de navegación; sonares; vigilancia; entre otros. En la Figura 1 se pueden observar algunos
ejemplos de aplicación.

$(LocalResource(joinpath("resources", "img", "fig1.png")))

En este trabajo se tendrá como objetivo poder localizar una fuente sonora, analizando  las señales que llegan a cada uno de los micrófonos pertenecientes a un arreglo a través de las herramientas desarrolladas en el curso. Además, sobre el final del trabajo, se analizarán dos señales de audio adicionales contenidas en los archivos "audio1" y "audio2".

"""

# ╔═╡ f9e7c093-b8f2-4f60-b1ad-268a3f3616b2
md"""
## Desarrollo
"""

# ╔═╡ 7f10b5e1-0007-4ef4-99a1-8a0d1a7e9df2
md"""
El objetivo principal del trabajo, como ya se ha mencionado, es detectar la posicion de una fuente sonora. Una alternativa para estimar la posición de una fuente sonora es utilizar un arreglo de micrófonos. Si
consideramos una fuente de sonido puntual, la difusión del sonido se realiza en forma esférica y a distancia
lo suficientemente lejos de la fuente el frente de onda se puede considerar plano ( Figura 2 ). La fuente puede
encontrarse por ejemplo en una habitación y el sonido será reflejado y absorbido por las paredes y techo,
produciéndose efectos de reverberación. Por otro lado, se puede deducir en forma intuitiva que si aumenta
la distancia entre el micrófono y la fuente de sonido la amplitud de la presión sonora disminuye.

$(LocalResource(joinpath("resources", "img", "fig2.png")))

En un arreglo de micrófonos las señales registradas por cada micrófono serán iguales salvo por algunas
pequeñas diferencias, que nos pueden ayudar a estimar la posición de la fuente sonora. La onda de sonido
de la fuente sonora viaja a una velocidad determinada que podemos considerar constante, y dependiendo
de la ubicación de los micrófonos el sonido registrado por cada uno de ellos tendrá un desfasaje temporal
(TDOA, del inglés Time Difference of Arrival) dado que los frentes de onda llegan a tiempos diferentes a
cada micrófono del arreglo. Si la fuente de sonido se encuentra en movimiento, la estimación de los TDOA
se debe realizar en un esquema de ventanas temporales de análisis.
"""

# ╔═╡ 50e02d9a-ad8b-4918-9491-6ba6ba4b7105
md"""
En lo siguiente realizaremos un análisis geométrico para describir como llega el frente de onda sonora a los
micrófonos del arreglo. Se puede suponer que la onda de sonora se desplaza en el aire a una velocidad
constante, de aproximadamente c = 340 m/s. También se puede considerar que es un frente de onda plano,
lo cual se cumple considerando que la fuente está lo suficientemente lejos de los micrófonos.


En la Figura 3 se observa un esquema de dos micrófonos, $M_i$ y $M_d$ , separados una distancia $d$, a los cuales
llega un frente de onda plano con un ángulo de incidencia θ, registrando las señales $s_i(t)$ y $s_d(t)$
respectivamente. El micrófono más lejano $M_i$ a la fuente tiene un retardo $T$ en la llegada del frente de onda
con respecto al micrófono más cercano $M_d$.

$(LocalResource(joinpath("resources", "img", "fig3.png")))
"""

# ╔═╡ 48fc1ac8-bd19-420b-9ffa-f94d6c0ba51f
md"""
Si la fuente emite una señal $s(t)$ y demora $t_o$ segundos en llegar al micrófono más cercano $M_d$ , podemos escribir:

$$\text{Ec 1:\qquad\qquad}s_d(t) = s(t-t_0) + r_d(t)$$
$$\text{Ec 2:\qquad}s_i(t) = s(t-t_0-\tau) + r_i(t)$$
$$\text{Ec 3:\quad}s_i(t)=s_d(t-\tau) + r_i(t) - r_d(t)$$

Donde las señales $r(t)$ son fuentes de ruido aditivas. Aquí hemos omitido los efectos de la habitación.
"""

# ╔═╡ 884c7637-eb5a-450e-b93a-dc8ba7814fd4
md"""
$(LocalResource(joinpath("resources", "img", "fig4.png")))
"""

# ╔═╡ e0f67768-4704-430e-88eb-b8d6a519c233
md"""
### Ejercicio 1

!!! info "Inspeccionar las señales"
    En el archivo `audios1.mat` se guardaron las señales registradas por un arreglo lineal de 5 micrófonos separados 5 cm ubicados en una habitación de 3x4 metros, según el esquema de la Figura 4. Se utilizó una frecuencia de muestreo de 48 kHz.


    Graficar en forma superpuesta las señales registradas por todos los micrófonos. Etiquetar ejes y sumar leyenda. Realizar una segunda figura de un segmento donde se puedan identificar los desplazamientos de las señales. Analizar los espectros de las señales mediante transformada de Fourier y espectrogramas.
"""

# ╔═╡ 46294fbb-c010-499f-bc8e-96c43f25a2d1
md"""
En esta primera sección se tendrá como objetivo el análisis de una señal de audio que llega a un arreglo lineal de 5 micrófonos separados 5 centímetros entre sí, y ubicados según la Figura 4. Para realizarlo, se comenzará recuperando los datos de la señal que llega a cada uno de los micrófonos con una frecuencia de muestreo ($f_S$) de 48KHz en la tupla $X_S$. Luego, se trabajará sobre estas señales, graficándolas, comparándolas, y, por ultimo, analizando su espectro.

"""

# ╔═╡ 0c2a3c23-cd83-46ef-888c-10146ac04108

md"""
Se decidió utilizar el Backend estándar o default para graficar ya que posee una interfaz gráfica muy amigable y es mejor trabajando con señales largas comparado con otros Backends similares, por ejemplo, "Plotly". Sin embargo, debido a la posibilidad que ofrece "Plotly" de utilizar marcadores sobre las señales, se tendrá un archivo auxiliar donde se usara este backend en ciertos puntos del trabajo donde se considere necesario.
"""

# ╔═╡ 6a7e0ffd-c055-4057-b1cb-f123536de183
md"""
**Definición de la frecuencia de muestreo**
"""

# ╔═╡ 64c61ca0-d827-4ce9-bb64-05541e6ffdad
#Se define la frecuencia de muestreo 
fs= 48000 

# ╔═╡ 56c0df38-c450-4fd0-91f9-9af6f35c9211
md"""
**Obtención de las muestras de las señales en la tupla $Xs$**
"""

# ╔═╡ 40d34e86-3797-4138-9ee2-5a0fc4f9b479
#Se colectan los datos de las señales
begin
	xs = [ collect(col) for col in eachcol(
			matread(joinpath("resources", "data", "audios1.mat"))["audios"]
			)]

	x1, x2, x3, x4, x5 = xs
	

end;

# ╔═╡ 17a55ed1-b1ca-4393-92b7-d630424e913b
md"""
#### Señales en el dominio del tiempo
"""

# ╔═╡ 9d081b37-5f5e-44af-9803-d34c3b97f4c0
md"""
**Audio de la señal captada por cada uno de los micrófonos**
"""

# ╔═╡ 4c15b9f8-fd1c-47ea-af2d-dfe28ab7e274
md"""
Se utiliza la función "SampleBuf" del paquete "SampledSignals" para poder escuchar las señales captadas por los microfonos. 
"""

# ╔═╡ c1e8523b-75d3-4020-9f4f-656fa3572ab5
md"""
Primer micrófono: 
"""

# ╔═╡ 9611dd8b-e614-4fd8-9053-7a9b4d7fa6ce
SampleBuf(x1,fs)

# ╔═╡ 29ae754e-e793-4543-a023-61450f274c9d
md"""
Segundo micrófono 
"""

# ╔═╡ 3a655117-994d-47f4-a1cb-8e603667d764
SampleBuf(x2,fs)

# ╔═╡ 7e479075-e0c4-487c-b37f-615354515b7b
md"""
Tercer micrófono 
"""

# ╔═╡ e7267aed-538b-4f9d-a193-8b386685856d
SampleBuf(x3,fs)

# ╔═╡ 756b8b31-2083-4b13-a964-6e8194956562
md"""
Cuarto micrófono 
"""

# ╔═╡ 25450c0d-5b7c-49cb-a71b-a75e8bd4b9f1
SampleBuf(x4,fs)

# ╔═╡ 18bc3d93-2d01-404d-87eb-272fa05f20b8
md"""
Quinto micrófono: 
"""

# ╔═╡ 22a600c7-7f06-4777-af2e-8a2a017b39c8
SampleBuf(x5,fs)

# ╔═╡ 7a588563-1a37-4601-9832-179aee054700
md"""
Se puede notar que la diferencia entre cada audio no es detectable para el oído humano, sin embargo, hay diferencias entre las señales que se analizaran más adelante. También es importante remarcar que se consideró como el primer micrófono al ubicado en el extremo izquierdo del arreglo de la **Figura 4**.
"""

# ╔═╡ 0a5489d5-17af-40f9-9fd1-f2049762380e
md"""
Se procederá graficando de forma superpuesta las señales muestreadas en cada uno de los cinco micrófonos en el dominio del tiempo, analizando sus características, semejanza y diferencias."""

# ╔═╡ 4511b425-1bee-4247-81f7-49a973f5dadb
let
	tiempo=range(0,length=length(x1),step=1/fs)
	plot(tiempo, x1;
			xlabel="Tiempo [s]",
			ylabel="Señal Xi",
			label="X1",
			legendtitle = "Señales",
			title="Señales de los distintos microfonos"
			)
	plot!(tiempo, x2;
			label="X2",
			)
	plot!(tiempo, x3;
			label="X3",
			)
	plot!(tiempo, x4;
			label="X4",
			)
	plot!(tiempo, x5;
			label="X5",
			)

end

# ╔═╡ 02dabd09-8e2c-442b-a4f5-f5be1223b0b1
md"""
En primer lugar, se observa que todas las señales, como era de esperarse por la **EC 3**, tienen una forma semejante a menos de un ruido y están desfasadas en tiempo. La similitud en la forma se puede entender ya que, al ser medida por micrófonos de las mismas características colocados a una distancia pequeña y con la misma frecuencia de muestreo, las señales que llegan a cada uno de los micrófonos son similares y estan medidas de forma analóga. 

Por otro lado, el desfasaje temporal corresponde a la distancia que hay entre los micrófonos ya que las ondas sonoras, al viajar a una velocidad determinada y finita,  tardaran distintos tiempos hasta llegar a los receptores. También se puede notar que los desfasajes temporal de cada señal respecto de la anterior son del orden de las centenas de micro segundos debido a que la distancia entre los micrófonos es de 5 cm y la velocidad del sonido en el aire la podemos considerar cercana a $c=340 \frac{m}{s}$ 
"""

# ╔═╡ 927e5b2c-6036-42a4-b68e-47ea716b5cd5
md"""
Para poder distinguir de mejor manera los desfasajes entre las distintas señales, se escaló el eje temporal observando solo durante 4 milésimas de segundo. Se nota claramente el desfasaje que existe entre las señales y que el máximo desfasaje se da entre los micrófonos que se encuentran en los extremos del arreglo.   
"""

# ╔═╡ 91ae961d-d65c-4bfb-b424-b2fe492f0d80
let
	tiempo=range(0,length=length(x1),step=1/fs)
	plot(tiempo, x1;
			xlabel="Tiempo [s]",
			ylabel="Señal Xi",
			label="X1",
			legendtitle = "Señales",
			title="Señales entre tiempos de 1.000 a 1.004 segundos",
			xlim=(1,1.004)
			)
	plot!(tiempo, x2;
			label="X2",
			)
	plot!(tiempo, x3;
			label="X3",
			)
	plot!(tiempo, x4;
			label="X4",
			)
	plot!(tiempo, x5;
			label="X5",
			)
	
end

# ╔═╡ 077118d3-a3f6-4519-8260-e842c79c53c4
md"""
#### Señales en el dominio de la frecuencia

"""

# ╔═╡ 6f709d2d-a75e-43fd-a1c2-ab0cfa39c131
md"""
Para analizar las señales en el dominio de la frecuencia se buscara su transformada de Fourier mediante la función "FFT" que provee el paquete "FFTW" de Julia.
"""

# ╔═╡ 04d6d252-da05-42e9-b34b-e3b6d4f7d391
md"""
###### Cálculo de las FFT de las señales
"""

# ╔═╡ daa16c6d-c22c-4253-a85e-072f3610b961
fft_x1=fft(x1)

# ╔═╡ 7ebeb41b-34a2-4a6a-97b2-6427c38556cb
fft_x2=fft(x2)

# ╔═╡ 8ce55995-f2f7-4df2-84ea-db450e0057a0
fft_x3=fft(x3)

# ╔═╡ 04f3b49b-f50b-44e9-b349-34bf85243113
fft_x4=fft(x4)

# ╔═╡ e81719d6-f382-4af4-ae69-d8f23fa8d7fc
fft_x5=fft(x5)

# ╔═╡ abdd912c-2211-4062-8963-3eecdd7fee8a
let
	
	freq= range(0;stop=fs,length=length(fft_x1))
	plot(freq , 
			abs.(fft_x1);
			xlabel="Frecuencia [Hz]",
			ylabel="FFT Xi [dB]",
			title="Espectros de las señales",
			label = "FFT X1" ,
			legendtitle = "FFT Xi",
			xlims = (0, fs/2),
			)
	
	plot!(freq , 
			abs.(fft_x2);
			label = "FFT X2",
			)
	
	plot!(freq, 
			abs.(fft_x3);
			label = "FFT X3" ,
			)
	
	plot!(freq, 
			abs.(fft_x4);
			label = "FFT X4" ,
			)
	
	plot!(freq, 
			abs.(fft_x5);
			label = "FFT X5",
			)


end

# ╔═╡ 337d0730-e4d8-4d2e-a020-2cd75781b6b7
md"""
Se puede observar que los espectros de las señales son muy similares entre sí y se corresponden con el audio escuchado. Se conoce que la voz humana, por lo general, emite en un rango de frecuencias bastante menor a 5 KHz y la mayor parte de su energía se concentra entre 75Hz y 500Hz aproximadamente, y los armónicos correspondientes hasta 3500Hz como se ve en el gráfico.

Por otro lado, es interesante hacer un analisis de la fase de las transformadas ya que se conoce que la relacion entre el deplazamiento temporal y su desfasaje tiene la forma 

$F[x(t − t_0)] = e ^{−jω_0t} \cdot X(jω)$ 

Utilizando la función "angle" de Julia se puede obtener la fase y graficarla. En este caso en particular, se acoto a un intervalo reducido de frecuencias para poder observar de mejor manera la diferencia de fases que hay entre las señales de los distintos micrófonos pertenecientes al arreglo.
"""

# ╔═╡ 51684a58-6584-49bd-86ef-ba8e86d0d8f9
let 
	#Se acorta las muestras entre ciertos valores para hacer mas liviano el calculo
	# 48000 fm y 499200 muestras 
	xi=20000
	xf=20010
	
	fft_x1r=fft_x1[xi:xf]
	fft_x2r=fft_x2[xi:xf]
	fft_x3r=fft_x3[xi:xf]
	fft_x4r=fft_x4[xi:xf]
	fft_x5r=fft_x5[xi:xf]
	
	freq= range(((xi*fs)/499200);stop=((xf*fs)/499200),length=length(fft_x1r))
	
	plot(freq,fftshift(angle.(fft_x1r)); 
		label="fft(x1) [Φ] ",
		title= "Fases de la FFT",
		legendtitle = "FFT's [Φ]",
		ylabel="Φ",
		xlabel="Frecuencia [Hz]"
		
	)
	plot!(freq,fftshift(angle.(fft_x2r)); 
		label="fft(x2) [Φ] ",
	
		
	)
	plot!(freq,fftshift(angle.(fft_x3r)); 
		label="fft(x3) [Φ] ",
	
		
	)
	plot!(freq,fftshift(angle.(fft_x4r)); 
		label="fft(x4) [Φ] ",
		
	)
	plot!(freq,fftshift(angle.(fft_x5r)); 
		label="fft(x5) [Φ] ",
		
	)
	

	
end 

# ╔═╡ 04da4c13-c2b7-404c-bb76-12969e2592d7
md"""
Por último, se realizó el espectrograma de las señales, el cual consiste en una gráfica en dos dimensiones y con una escala cromática que representa la energía del contenido frecuencial de la señal a lo largo del tiempo. El espectrograma es el resultado de calcular el espectro de una señal por ventanas de tiempo, por lo cual, antes de proceder se realizará una breve comparación de distintos tipos de ventanas y sus características. Esto será de mucha utilidad para poder obtener los espectrogramas de forma correcta y para realizar otras actividades que se verán más adelante. 
"""

# ╔═╡ 330b9b0a-4d95-4d0b-86e3-b8fdf96099c2
md"""
Las características principales que son de interés de una ventana son el ancho de su lóbulo principal y la magnitud de sus picos secundarios en el dominio frecuencial, ya que ,al convolucionar las ventanas con las distintas señales en frecuencia, estos parametros determinaran en gran medida la precisión.

Se procedera graficando distintos tipos de ventanas y comparandolas. 
"""

# ╔═╡ 620d4bd2-08d5-43b6-b115-0bd005ccc0aa
let 
	N=15
	xf1=fftshift(abs.(fft(padright(rect(N),1000))))
	xf2=fftshift(abs.(fft(padright(hanning(N),1000))))
	xf3=fftshift(abs.(fft(padright(hamming(N),1000))))
	
	ns= range(-π,length=1000,stop=π) 
	plot(ns,xf1;xlims=(-π,π),
		title="Espectro de las distintas ventanas", 
		ylabel="|H(Ω)|" , 
		xlabel=" Ω",
		label= "Ventana Rectangular") 
	
	plot!(ns,xf2;xlims=(-π,π),	
		label= "Ventana de Hanning" 
		)
	
	plot!(ns,xf3;xlims=(-π,π),
		label="Ventana de Hamming" 
		)
		

end 

# ╔═╡ fed25724-ba1f-4ea3-be41-7d9f93409d51
let 
	N=15
	xf1=fftshift(log.(abs.(fft(padright(rect(N),1000)))).+eps())
	xf2=fftshift(log.(abs.(fft(padright(hanning(N),1000)))).+eps())
	xf3=fftshift(log.(abs.(fft(padright(hamming(N),1000)))).+eps())
	ns= range(-π,length=1000,stop=π) 
	plot(ns,xf1;xlims=(-π,π),
		title="Espectro de las ventanas en escala logaritmica", 
		ylabel="|H(Ω)| log" , 
		xlabel=" Ω",
		label= "Ventana Rectangular",
		ylims=(-12,5) 
		)
	plot!(ns,xf2;xlims=(-π,π),	
		label= "Ventana de Hanning" 
		)
	
	plot!(ns,xf3;xlims=(-π,π),
		label="Ventana de Hamming" 
		)


end 

# ╔═╡ 04bdd425-69cb-45e9-a114-99dcf7cdefed
md"""
Se observa claramente que la ventana rectangular tiene el lóbulo principal más angosto, pero a su vez es la que posee lóbulos secundarios mayores y que decaen de una forma mucho más lenta que las otras dos ventanas con las cuales se la está comparando. Por otro lado, entre las ventanas de Hamming y Hanning la diferencia no es tan notoria como con la rectangular, pero se ve que, para la primera mencionada, los primeros lóbulos secundarios son menores pero luego decaen de una manera más lenta. También es importante tener en cuenta que cuantos más puntos se tomen de las ventanas discretas, sus espectros serán cada vez más angostos y se aproximaran a la delta de dirac ideal.
"""

# ╔═╡ 8e3a72a2-15a4-47fd-be48-9d64cf2b693d
md"""
Para realizar los espectrogramas en esta parte se utilzara una ventana de hanning ya que, si bien el ancho del lobulo principal de su espectro es mayor que la ventana rectangular, sus lóbulos secundarios tienden a decaer mucho más rápido. Además se utilizara una ventana con 512 puntos ($0.011\ s$) para obtener, en frecuencia, un lóbulo principal lo suficientemente angosto para lograr un espectrograma representativo. 
"""

# ╔═╡ efae1d01-bd7b-4865-988d-4ecdc750b93e
let 
	specplot(x1;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 1",
			fs) 
end 

# ╔═╡ 956d3df4-c08c-40e4-91e3-8aa59bb8476c
let 
	specplot(x2;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 2",
			fs) 
end 

# ╔═╡ 580d94c3-9fae-48fa-b89e-3200dc869318
let 
	specplot(x3;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 3",
			fs) 
end 

# ╔═╡ b0d853ec-778b-4d12-b2c7-87a32a38be01
let 
	specplot(x4;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 4",
			fs) 
end 

# ╔═╡ fe847b3e-720e-4ee8-a7b2-6230e9e023df
let 
	specplot(x5;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 5",
			fs) 
end 

# ╔═╡ fda59bad-8109-4a74-beb8-feea929b05d1
md"""
Debido a que la señal proviene de un hombre hablando en inglés, en el espectrograma se observan franjas verticales que se corresponden a cuando está emitiendo sonido, y como es de una voz masculina, la mayoría de su energía se encuentra para frecuencias menores a 5KHz.
""" 

# ╔═╡ 5ad1cb51-d8ca-4f69-859b-f1f10e56f2a1
md"""
### Ejercicio 2

!!! info "Inspeccionar los retardos"
    Utilizando la figura del ejercicio anterior, estimar los retardos de llegada a todos los micrófonos. Suponer una posible posición de la fuente de sonido con respecto a los micrófonos a partir de los valores estimados de los retardos.
"""

# ╔═╡ 333940e7-3ff1-4361-b895-c888f8e01b41
md"""
#### Cálculo estimado de los retardos  
"""

# ╔═╡ fce74867-93bf-4017-8d75-b046a47196de
md"""
En este inciso se calcularán los retardos aproximados entre cada señal utilizando el grafico de la figura anterior, para lo cual se hizo un archivo adicional donde se utilizó un backend más lento pero que permite observar los valores de la señal en puntos determinados. Como resultado se obtuvo la figura que se encuentra a continuación;
"""

# ╔═╡ 11d7de61-11e0-4c9c-9814-e243c0ba4f89
md"""
$(LocalResource(joinpath("resources", "img", "retardos2.png")))
"""

# ╔═╡ c26290a4-853e-415d-9edb-1c7f59ed50d6
md"""
En los gráficos se buscaron los tiempos en los cuales las distintas señales pasaban por el mismo punto o lo más próximo posible, por ejemplo, en la señal $x_1$ para un tiempo $t_1=1.005$, el valor correspondiente en el eje Y es de $y_1=-0.0129$, para la señal dos, el valor más próximo a $y_1$ se daba en el tiempo $t_2=1.005063$ , y de esta manera se midió el desfasaje entre cada par de señales, luego se obtuvo la tabla que se puede observar a continuación con los valores de los distintos retardos aproximados.
"""

# ╔═╡ 3209558d-c77a-406c-a90e-7a41d115f025
md"""
$(LocalResource(joinpath("resources", "img", "retardostabla.png")))
"""

# ╔═╡ 09e8c69b-0af7-42bf-a66e-6eaff856300f
md"""
En este inciso, para aproximar la posición de la fuente, no se plantearon las rectas y se buscó su intersección ya que es algo que se realiza más adelante en el trabajo y no tiene mucho sentido aplicarlo con valores de retardos tan aproximados. Por lo tanto, solo se analizaron los tiempos de retardo con el objetivo de tener una idea aproximada acerca de donde se encontrará la fuente. Con la información que se posee, se puede concluir que la fuente se encontrara a la izquierda del primer micrófono ya que la señal llega en primer lugar al micrófono ubicado en el extremo izquierdo del arreglo."""

# ╔═╡ 9a13e5cb-300c-4519-8d5e-703e948fbb7b
md"""
### Ejercicio 3

!!! info "Calcular los retardos"
	Calcule las correlaciones entre cada par de señales de micrófonos consecutivos en el dominio temporal (Ec.4) y mediante la IDFT de GCC-PHAT (Ec. 8). Obtenga los retardos a partir de ambos métodos.
"""

# ╔═╡ cf74bf4c-999d-47db-9480-70feaa7e5699
md"""
Una forma de estimar en forma automática el retardo de llegada de una señal sonora a un micrófono
respecto de otro es utilizando la función de correlación cruzada, que permite medir el grado de similitud
entre dos señales. En tiempo discreto la correlación cruzada entre dos señales `x[n]` e `y[n]` se define como

$$\text{Ec 4:\qquad}r_{xy}[l]=\sum_{n=-\infty}^\infty x[n]y[n-l]$$
"""

# ╔═╡ 4fffb4ed-7142-4205-9eeb-d6bf85cce9b8
md"""
El índice $l$ es un parámetro de desplazamiento temporal, que determina el tiempo relativo entre ambas
señales. El cálculo de esta secuencia resulta impreciso en ambientes sumidos en ruido. Como alternativa,
se puede recurrir a una propiedad que vincula a una secuencia de correlación cruzada entre dos señales
con sus respectivas transformadas de Fourier en Tiempo Discreto:

$$\text{Ec 5:\qquad}\mathcal{F}(r_{xy}[l])=X(\Omega) \overline{Y(\Omega)}$$

Donde $\mathcal{F}(⋅)$ representa la transformada de Fourier, $X(Ω)$ es la transformada de Fourier de la señal $x[n]$ e $\overline{\space⋅\space}$ es el complejo conjugado de la transformada de Fourier de la señal y[n].
"""

# ╔═╡ 4460e520-2ddc-41a6-838d-380094d25f9a
md"""
Una alternativa es una técnica basada en correlación de señales en el dominio frecuencial llamada GCC-PHAT (del inglés, _Generalized Cross Correlation with Phase Transform_), que presenta mayor robustez en
ambientes ruidosos. Esta se define de la siguiente forma:

$$\text{Ec 6:\qquad}G_{PH}[k]=\frac{X[k]\overline{Y[k]}}{|X[k]||Y[k]|}$$

Donde $X[k]$ representa la Transformada de Fourier Discreta (DFT) de la señal $x[n]$ y $\overline{Y[k]}$ es el complejo conjugado de la DFT de la señal $y[n]$. El denominador de la ecuación actúa como normalizador a la vez que
se preserva la información de fase. La ecuación se puede reescribir considerando la Ec. 3, como:

$$\text{Ec 7:\qquad}G_{PH}[k]=e^{j \frac{2\pi}{N} k \tau}$$
"""

# ╔═╡ 24345e17-2d95-4846-970f-9ff8056396e5
md"""
Calculando la transformada inversa obtenemos:

$$\text{Ec 8:\qquad}g_{PH}[l]=\delta(l-\tau)$$

En la práctica no obtenemos un $δ(l − τ)$ que nos marcaría la posición del retardo, pero sí una función que
presenta un pico máximo en $T$. En la Figura 5 se muestra un ejemplo de aplicación.

$(LocalResource(joinpath("resources", "img", "fig5.png")))
"""

# ╔═╡ 25dfbbd9-9bd0-4047-b503-4e8ba28c6976
md"""
#### Cálculo de las correlaciones
"""

# ╔═╡ 98e32733-fddc-4503-93e3-0a5316bb0043
md"""
##### Cálculo en el dominio temporal
"""

# ╔═╡ 480b8cf9-7f7f-4345-a451-6f4ae8628217
md"""
Con el objetivo de calcular la correlación temporal entre cada par de señales de micrófonos consecutivos en el dominio temporal, se implementara la **Ec.4** a través de la función "xcorr" que brinda julia. Se obtienen los siguientes resultados;
"""

# ╔═╡ ff458a1f-5ab7-4801-96c3-e7c482e3de86
begin
	corr_x21 = xcorr(x2,x1)
	corr_x32 = xcorr(x3,x2) 
	corr_x43 = xcorr(x4,x3) 
	corr_x54 = xcorr(x5,x4) 
end ;

# ╔═╡ 108745cd-060a-4cb9-8fca-f2b9df0908fe
let
	tiempo=range(0,length=length(corr_x21),step=1/(fs))
	plot(tiempo,corr_x21;
		xlims=(10.399,10.401),
		title="Correlación entre las señales Xi y Xj",
		xlabel="Tiempo [s]",
		ylabel="Correlación",
		label="corr (x2,x1)")
	plot!(tiempo,corr_x32;
	label="corr (x3,x2)",)
	
	plot!(tiempo,corr_x43;
	label="corr (x4,x3)",)
	
	plot!(tiempo,corr_x54;
	label="corr (x5,x4)",)
end 

# ╔═╡ 3080c05b-7bd5-41b9-9f3d-a03dfffcfe00
md"""
##### Cálculo mediante IDFT de GCC-PHAT
"""

# ╔═╡ ba69d533-7991-459e-b6c0-d84fade6f473
md"""
Para el cálculo mediante IDFT de GCC-PHAT se implementó la **ecuación 6** y se le realizo su anti transformada con la función "ifft" de Julia. Esta implementación puede verse en la función propia "calculo_gph".
"""

# ╔═╡ b246f5a9-edef-42f0-8e2b-56f1ca29b5ef
function calculo_gph(fftx,ffty) 
	#calculo la GPH en el dominio frecuencial 
	GPHnum=fftx.*conj(ffty)
	GPHden=abs.(GPHnum)
	#le sumo un termino chico constante para evitar problemas numericos 
	GPHden.+=std(GPHden) * 1e-3
	gph= real(ifft(GPHnum./GPHden))
	#devuelvo la antitransformada
	return gph
	
end

# ╔═╡ 4eb8c90b-dece-4e72-839b-b241a933e502
begin 
	gph_x21=calculo_gph(fft_x2,fft_x1)
	gph_x32=calculo_gph(fft_x3,fft_x2)
	gph_x43=calculo_gph(fft_x4,fft_x3)
	gph_x54=calculo_gph(fft_x5,fft_x4)
end ;

# ╔═╡ bd28a4a6-16fe-4b20-92ab-d029d0b07d5b
let
	
	tiempo=range(0,length=length(x1),step=1/fs)
	plot(tiempo,(gph_x21);
		title="Correlación de señales mediante GCC-PATH",
		xlims=(0,0.0003),
		legendtitle="Correlación señal Xi-Xj",
		label="corr (x2-x1)",
		ylabel="gph(xi,xj)",
		xlabel= "Tiempo [s]"
	)
	plot!(tiempo,(gph_x32);
		label="corr (x3-x2)"
	)
	plot!(tiempo,(gph_x43);
		label="corr (x4-x3)"
	)
	plot!(tiempo,(gph_x54);
		label="corr (x5-x4)"
	)

end

# ╔═╡ 9e8f736d-7339-4789-8780-1a4e162834cf
md"""
#### Cálculo de los retardos   
"""

# ╔═╡ 151dd287-1f69-44c8-8b84-216c3154cdb3
function hallar_retardo_temp(vect,fs) 
	pos=argmax(vect)
	
	#el if para que no se rompa si es negativo
	if pos>length(vect)*1.5
		pos=length(vect)-pos
	end
	
	retardo= (pos)/fs 
	return retardo
end

# ╔═╡ 8ea866ea-4374-428b-ae0f-dabef74d1ccb
function argmax_edges(x, n)

	# Si tiene menos que 2n + 1 elementos, buscar en todos lados
	length(x) <= 2n + 1 && return argmax(x)

	return 1 + mod(argmax(view(circshift(x, n), 1:2n+1)) - n - 1, length(x))
end

# ╔═╡ fa3bf2bf-42b9-47d6-ae51-9bfcf7bd9bdf
function hallar_retardo_f(gph,fs) 
	max_voice_f0 = 500. # Hz
	n_period_min = round(Int, fs / max_voice_f0)

	imax = argmax_edges(gph, n_period_min)

	nlim = length(gph) ÷ 2

	return (mod(imax - 1 + nlim, length(gph)) - nlim) / fs
end

# ╔═╡ e30ec405-1ce3-44f5-887b-36ac0207ee18
md"""
##### Cálculo mediante correlaciones temporales
"""

# ╔═╡ 489f1aaf-40f8-4822-b382-a8e59233dad6
ret_x21_temporal=hallar_retardo_temp(corr_x21,fs)- length(x1)/fs

# ╔═╡ 375d2e36-d9c8-4b22-8cff-d4845a005489
ret_x32_temporal=hallar_retardo_temp(corr_x32,fs)- length(x1)/fs

# ╔═╡ 7d0ccb56-6061-443e-abbb-92e719f7cb64
ret_x43_temporal=hallar_retardo_temp(corr_x43,fs)- length(x1)/fs

# ╔═╡ d0a8248f-633d-46ac-b2bc-95811b67c7ec
ret_x54_temporal=hallar_retardo_temp(corr_x54,fs)- length(x1)/fs

# ╔═╡ 3d57fe99-91ae-4312-9a45-4990b79d75b7
md"""
##### Cálculo mediante IDFT de GCC-PATH
"""

# ╔═╡ d00002d4-1e9a-42da-9733-d1970a368de7
ret_x21_gph=hallar_retardo_f(gph_x21,fs)

# ╔═╡ 0284914d-16ea-45b8-9d91-73fdc12fa4d9
ret_x32_gph=hallar_retardo_f(gph_x32,fs)

# ╔═╡ e5ca455c-1e4f-4f69-a4a3-dfe687b4551e
ret_x43_gph=hallar_retardo_f(gph_x43,fs)

# ╔═╡ 20b349d2-fbaf-4fbe-89b4-292fcdf87e0a
ret_x54_gph=hallar_retardo_f(gph_x54,fs)

# ╔═╡ f750393e-070d-4e11-880f-4280025639a0
md"""
Viendo los resultados obtenidos en el cálculo de los retardos es importante tener en cuenta que los mismos no serán un valor muy preciso. Esto se asocia a la discretización de la señal, como se ha mencionado, la frecuencia de muestreo es de $fs=48000$, es decir, la distancia mínima que tendremos entre dos muestras sucesivas es de $\frac{1}{fs}$ que es un valor comparable al valor total de los retardos, por lo tanto, al calcularlos se introduce un error muy grande. En los siguientes ejercicios del proyecto se buscarán formas de procesar la señal de modo que se puedan obtener retardos con mayor precisión. 
"""

# ╔═╡ 4f94c873-1b3a-44f5-8b85-496bdd9321ba
md"""
### Ejercicio 4

!!! info "Estimar evolución temporal de retardos"
	Estimar los retardos de llegada y graficar su evolución temporal utilizado el algoritmo propuesto. Realizar los histogramas de los retardos calculados para cada micrófono. Obtener un valor representativo de retardo para cada señal. Estimar y graficar la posición de la fuente.
"""

# ╔═╡ 3071adcd-958f-4919-8ff5-60116b38aefb
md"""
En este ejercicio se realizara una evolución temporal de los retardos utilizando un algoritmo de estimación por ventanas, luego se realizara el histograma de los mismos y, luego, se calcularan los retardos y se estimara la posición de la fuente.
"""

# ╔═╡ 0a67d45c-4297-4adc-a998-5fcc22d11436
md"""

El algoritmo de estimación de los retardos, estimados por ventanas y par de micrófonos, se puede escribir
cómo:

-  $w(n)$: ventana de $N$ muestras.
-  $\Delta n$: Número de muestras del desplazamiento de la ventana.
-  $x(n)$: señal de audio registrada por el micrófono $i$−ésimo.
-  $y(n)$: señal de audio registrada por el micrófono $(i + 1)$−ésimo.

Para cada par de señales $(x, y)$, hacer:

- ``n_0 \leftarrow \frac N 2``
- Mientras $n_0+\frac N 2 <$ tamaño de $x$, hacer
    - ``\text{DFT}_x \leftarrow \text{DFT}{x(n) w(n-n_0)}``
    - ``\text{DFT}_y \leftarrow \text{DFT}{y(n) w(n-n_0)}``
    - ``G_{ph} \leftarrow \frac{\text{DFT}_x \text{DFT}_y^*}{|\text{DFT}_x| |\text{DFT}_y|}``
    - ``m\leftarrow \max_k\left(\text{IDFT}{G_{ph}}(k)\right)``
    - Si ``m>\frac N x \Longrightarrow m \leftarrow m - N``
    - ``\tau_{xy}(n_0) \leftarrow \frac{m}{f s}``
    - ``n_0 \leftarrow n_0 + \Delta n``
"""

# ╔═╡ 14372d6c-030f-450c-9ac8-865ccdaa5ab5
md"""
Si $\tau$ es el retardo entre dos micrófonos separados una distancia $d$, el ángulo de llegada del frente de onda
plano se pude estimar como:

$$\text{Ec 9:\qquad}cos(\theta) = \frac{c \tau}{d}$$
$$\text{Ec 10:\quad}\theta=cos^{-1}\left(\frac{c \tau}{d}\right)$$

Donde $c$ es la velocidad del sonido. En un arreglo de más de dos micrófonos, podemos estimar la posición
de la fuente encontrando el punto de intersección de las rectas que pasan por cada uno de los micrófonos y
de pendientes:

$$\text{Ec 11:\qquad}m_i=tg(\theta) = tg\left(cos^{-1}\left(\frac{c \tau_i}{d}\right)\right)$$
"""

# ╔═╡ 876bc7c7-d937-499f-8b90-c4b2cdaf39ea
md"""
En la figura siguiente se muestra un esquema de la estimación de la posición de la fuente a partir de los retardos,
utilizando la Ec 11.

$(LocalResource(joinpath("resources", "img", "fig6.png")))
"""

# ╔═╡ 2d7df849-334e-4469-91d6-6a2b8ad98ed9
md"""
#### Evolución temporal de los retardos calculados con Gph   
"""

# ╔═╡ 78dd184d-66bd-4467-81d9-dab4cb870fb4
md"""
Se implemento la función de evolución temporal siguiendo los pasos que se plantean anteriormente, donde se comienza definiendo la cantidad de muestras de la ventana, el desplazamiento de la misma y luego, se va calculando el valor del retardo para pequeñas ventanas de tiempo con el objetivo de obtener una evolución temporal del retardo.
"""

# ╔═╡ 8c943d93-4a37-43a7-874b-9891b7aa2004
function ev_temp(N, delta_n, x, y,fs)
	i = 1
	n_0 = convert(Int64,N/2)
	
	#defino el tipo de ventana 
	ventana = hanning(N)
	
	tau_xy = zeros(convert(Int64,round(Int,(length(x)-N) / delta_n))+1)
	
	while n_0 + N/2 < length(x)
		izq = convert(Int64, -N/2+n_0+1)  
		der = convert(Int64, N/2+n_0)
		
		fft_x = fft(x[izq:1:der] .* ventana)
		fft_y = fft(y[izq:1:der] .* ventana)
		
		gph = calculo_gph(fft_y, fft_x)
		
		m = hallar_retardo_f(gph,fs)
	
		tau_xy[i] = m
		
		i = i + 1
		n_0 = n_0 + delta_n
	end		
	
	return tau_xy
	
end

# ╔═╡ 7e9c2d80-fb2a-4afa-901d-e2081c9dfe59
md"""
**Definición del numero de puntos de la ventana y su desplazamiento**
"""

# ╔═╡ e6f911a7-18d3-4e38-8655-5d87b7965a59
md"""
En este caso en particular no tiene mucho sentido definir un numero de muestras de la ventana muy grande ni un paso muy chico ya que la fuente estará quieta, la velocidad del sonido la consideramos constante y la señal no tiene ruido. Se utilizará una ventana de hanning de 2048 puntos (0.04266 s) y un solapamiento del 50% ya que la ventana de hanning tiene la característica de que el módulo de sus lóbulos secundarios decae rápidamente y el ancho de su lóbulo principal se puede controlar mediante la cantidad de muestras de la ventana. Ademas el ancho de esta ventana se mantendra constante (en tiempo) durante todo el proyecto para poder comparar resultados. 
"""

# ╔═╡ 94ff3028-92d1-421f-9b05-d1cf300a7b2e
N1=2048

# ╔═╡ 6a5bf067-9397-47a1-9532-12b565d53250
delta_n1=convert(Int64,N1/2)

# ╔═╡ 5511ec91-c9b2-4068-98e6-604c6229d23a
begin
	evtemp_ret21=ev_temp(N1,delta_n1,x1,x2,fs)
	evtemp_ret32=ev_temp(N1,delta_n1,x2,x3,fs)
	evtemp_ret43=ev_temp(N1,delta_n1,x3,x4,fs)
	evtemp_ret54=ev_temp(N1,delta_n1,x4,x5,fs)
end;

# ╔═╡ 0fff5207-1645-4787-926c-43c9336cfef0
md"""
Se obtiene como resultado la siguiente evolución de los retardos en función del tiempo: 
"""

# ╔═╡ 4eeeb935-a768-4249-818e-7173e2ae8dda
let 
	tiempo=range(0,length=length(evtemp_ret21),stop=length(x1)/fs)

	plot(plot(tiempo, evtemp_ret21;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X2-X1",
			label="retardo",
			ylims=(5e-5,10e-5)
			)
		, plot(tiempo, evtemp_ret32;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X3-X2",
			label="retardo",
			ylims=(5e-5,10e-5)
			),
		plot(tiempo, evtemp_ret43;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X4-X3",
			label="retardo",
			ylims=(5e-5,10e-5)
			),
		plot(tiempo, evtemp_ret54;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X5-X4",
			label="retardo",
			ylims=(5e-5,10e-5)
			) 
		
		)
end 

# ╔═╡ 4ee02a45-884c-4033-95e8-963c9094b7ab
md"""
Para obtener un valor representativo de los retardos se tomara la mediana del vector temporal a partir de la función "median" de Julia. Donde la mediana representa el valor de la variable de posición central en un conjunto de datos ordenados.
"""

# ╔═╡ 38164d3c-e368-4383-b9aa-9d4f1ebf441c
ret_x21_prom=median(evtemp_ret21)

# ╔═╡ 340d90bc-dfe8-46cc-a4b6-b6b63c5b019a
ret_x32_prom=median(evtemp_ret32)

# ╔═╡ 3f050d4b-9e17-4f55-9b52-d8373b5950f9
ret_x43_prom=median(evtemp_ret43)

# ╔═╡ 02b8c945-0471-401c-9afe-6f6a8c9f000c
ret_x54_prom=median(evtemp_ret54)

# ╔═╡ 7492e39a-9e41-47ce-9bc0-cf83a6e14de7
md"""
Como se observa en el cálculo de los retardos en función del tiempo, en los retardos entre las señales 1,2,3 y 4 no tiene sentido realizar un espectrograma ya que el resultado sería una delta en el valor correspondiente, por lo tanto, solo se realizó el histograma para el caso del retardo de las señales 4 y 5. 
"""

# ╔═╡ 766747af-23f1-498c-b047-68dd7b210e96
histogram(evtemp_ret54;
	bins=500,
	xlims=(6e-5,8.5e-5),
	orientation = :v,
	xlabel="Retardo [s]",
	ylabel="Cantidad de muestras",
	title = "Histograma del retardo de la señal 4 y 5"
,label="retardo")

# ╔═╡ 71c4be28-5702-4ff3-80e2-505f3630825c
md"""
#### Estimación de la posición de la fuente
"""

# ╔═╡ 874ef93e-d954-4949-9ae5-7941b5041060
md"""
En esta sección se buscará encontrar la posición de la fuente con los retardos calculados entre cada par de señales, los cuales pueden ser calculados mediante la correlación temporal, el algoritmo de GCC-path original o realizando una evolución temporal de los últimos a través de un ventaneo en tiempo y quedarse con un valor representativo para esos retardos que, en este caso, la mediana.
"""

# ╔═╡ 4a7cf4af-f5e7-43a9-8a40-f0a614a3c7b7
md"""
**Definición de la distancia entre microfonos [m]**
"""

# ╔═╡ e63c2382-44fb-4b7b-bb10-e733a02cf887
#distancia entre microfonos 
d=0.05

# ╔═╡ 504e8eb7-6521-422d-94ab-5aeae670e5e7
md"""
**Definición de la velocidad del sonido en el aire [m/s]**
"""

# ╔═╡ d15a12c9-4681-4bee-ad72-4e7c7147232f
#velocidad del sonido en el aire
c=340 

# ╔═╡ b1eea814-27a8-41a6-91f5-5cd34cef4057
md"""
**Definición de la función que genera las rectas**
"""

# ╔═╡ 932dc23b-a03e-49fc-ad23-87e52cb3354d
md"""
Se implemento una función que genera las rectas siguiendo el cálculo de la **ecuación 11** y tomando como primer micrófono del arreglo el que se encuentra en el extremo izquierdo.
"""

# ╔═╡ c10b5c90-9ea4-4bd6-9dab-bd8dfdd11721
function recta(retardo, posx, posy, x) 
	m=-tan(acos((c*retardo)/(posx-2)))
	b= 1- m * posx 
	
	y=m .* x .+b 
end

# ╔═╡ 4990514a-0aea-457c-ad2f-b7f45e18b216
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_temporal,2+d,1,x)
	recta2= recta(ret_x32_temporal+ret_x21_temporal,2+2*d,1,x)
	recta3= recta(ret_x43_temporal+ret_x32_temporal+ret_x21_temporal,2+3*d,1,x)
	recta4=      recta(ret_x54_temporal+ret_x43_temporal+ret_x32_temporal+ret_x21_temporal,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la fuente con correlación temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ d082c5e0-7ecb-41cf-876d-f8f53f55ece1
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_gph,2+d,1,x)
	recta2= recta(ret_x32_gph+ret_x21_gph,2+2*d,1,x)
	recta3= recta(ret_x43_gph+ret_x32_gph+ret_x21_gph,2+3*d,1,x)
	recta4= recta(ret_x54_gph+ret_x43_gph+ret_x32_gph+ret_x21_gph,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente con Gph",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 67961b6d-163d-477c-b434-6a1e02e86ad0
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_prom,2+d,1,x)
	recta2= recta(ret_x32_prom+ret_x21_prom,2+2*d,1,x)
	recta3= recta(ret_x43_prom+ret_x32_prom+ret_x21_prom,2+3*d,1,x)
	recta4= recta(ret_x54_prom+ret_x43_prom+ret_x32_prom+ret_x21_prom,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 6766a189-b48b-45af-9a6c-1801bc002778
md"""
Como se puede observar en las figuras, no es posible hallar una buena aproximación acerca de la ubicación de la fuente sonora, lo cual coincide con la explicación que se desarrolló en el cálculo de retardos. En este caso, se puede entender a partir de realizar el cálculo de la precisión que se obtiene sobre las pendientes de las distintas  rectas, teniendo en cuenta los valores de la frecuencia de muestreo, la velocidad del sonido y la distancia a la que se hallan los micrófonos, se llega a la conclusión de que únicamente se tendrá un numero de $7$ muestras para dividir los $90^{\circ}$ de la pendiente, por lo tanto, el error será muy grande, las rectas no se cruzaran en un único punto y no se podrá aproximar de forma correcta la posición de la fuente. 
"""

# ╔═╡ 14b88f72-4c0f-49ae-a332-e59bb6e1b9ef
md"""
**Calculo auxiliar**

$m_i=tg(\theta) = tg\left(cos^{-1}\left(\frac{c \tau_i}{d}\right)\right)$

$Si:\   0^{\circ}<m_i < 90^{\circ} \Rightarrow 0 < \frac{c \tau_i}{d} < 1$

$\Rightarrow 0 < N < 7$ 
"""

# ╔═╡ 47408390-2d25-4649-8ad9-651172be2236
md"""
## Ejercicio 5

!!! info "Repetir sumando ruido"
	Agregar, en forma independiente, un ruido blanco con una SNR de 20 dB a las señales capturadas por los micrófonos. Escuchar ambas versiones y comparar sus espectros. Repetir los ejercicios 1 a 4 con las nuevas señales.
"""

# ╔═╡ 6f03ba67-24d3-4757-929a-70840de5ce12
md"""
####  Señal con ruido
"""

# ╔═╡ 4ed9a0f3-8d7a-43bb-9feb-51b378a9213d
md"""
Un ruido blanco es una señal que se caracteriza por contener todas las frecuencias y que todas ellas muestren la misma potencia, en este caso, le sumaremos a la señal original que se encontraban libres de ruido uno blanco con una SNR de 20 dB. La relación señal ruido (SNR) se puede definir como se ve a continuación:
"""

# ╔═╡ 2dbdbfeb-09aa-4b36-b08a-91c0ff9ec3d2
md"""
$$\text{Ec 12:\qquad}SNR=10\log_{10}\left(\frac{\sum_{n=0}^{N-1} |s(n)|^2}{\sum_{n=0}^{N-1}|r(n)|^2}\right)$$
"""

# ╔═╡ f22ed4be-1fbd-49be-b85c-4a8a86675c71
md"""
Para generar el ruido blanco se utilizó la función "randn" de Julia que da como resultado un numero aleatorio normalmente distribuido, por lo tanto, tendrá una media de 0 y una varianza de 1. Luego, para obtener el ruido correspondiente, es necesario multiplicar lo generado por "randn" por una constante W, cuyo valor está determinado por las dos señales a sumar y la SNR. 

Por otro lado, las señales de audio, al tener un valor medio nulo, se le puede calcular la potencia media como $P_s = Var(s)$. Aplicando las propiedades de la varianza se llega al siguiente valor de la constante W;


$W=\sqrt{\frac{P_s}{P_r \cdot  10^{\frac{SNR}{10}}}} \approx\sqrt{\frac{P_s}{10^{\frac{SNR}{10}}}}$

"""

# ╔═╡ 3458f44c-e0e0-42cb-8ca0-7fdf6cc34b01
md"""
Donde $P_s$ es la potencia de la señal y $P_r$ la correspondiente al ruido.
"""

# ╔═╡ c41b8cf5-42bf-47bd-8cac-bc9784bd2c1e
md"""
**Definición de la constante de ruido**
"""

# ╔═╡ 783d3941-c0de-401c-99d8-7b36817b51c9
W(audio,snr)=sqrt(var(audio)/((10^(snr/10))))

# ╔═╡ 622f34ee-a95e-456e-9a97-548a6b27175a
md"""
**Definición de los ruidos**
"""

# ╔═╡ c86cb561-2d4a-4821-99df-fac99fe00375
ruido1=randn(length(x1)).*W(x1,20)

# ╔═╡ 56b4bbb8-8f9e-4ee2-ac17-6fd141fe706d
ruido2=randn(length(x2)).*W(x1,20)

# ╔═╡ 56750751-d4d2-429c-b485-e872accb7ce7
ruido3=randn(length(x3)).*W(x1,20)

# ╔═╡ b6c5f649-517c-4373-ad6d-3ce54bc9f6df
ruido4=randn(length(x4)).*W(x1,20)

# ╔═╡ 9965a443-afed-42aa-854c-663e352cf806
ruido5=randn(length(x5)).*W(x1,20)

# ╔═╡ 56c0ed95-4b2f-4c40-958d-8c067e4880a2
md"""
**Señales con ruido**
"""

# ╔═╡ c5d41bef-ec2f-4bc4-8faa-a16b99c328c4
md"""
X1:
"""

# ╔═╡ ad5b7d2c-25b7-4286-bf40-776eeb404247
begin
	x1_r=x1.+ruido1
	SampleBuf(x1_r,fs)
end 

# ╔═╡ a9655e9a-0539-4c8a-b5b3-d585c2877f76
md"""
X2:
"""

# ╔═╡ 849516fe-636b-4e06-827b-29a884f2fad3
begin
	x2_r=x2.+ruido2
	SampleBuf(x2_r,fs)
end 

# ╔═╡ fea1823c-4715-47bc-a413-647291e0178c
md"""
X3:
"""

# ╔═╡ 967ba308-b327-4a84-a723-408b02dbb5db
begin
	x3_r=x3.+ruido3
	SampleBuf(x3_r,fs)
end 

# ╔═╡ 0d8c68f9-3f3e-488f-bf1f-096800b9976f
md"""
X4:
"""

# ╔═╡ aec82054-fa4b-4a99-9d37-e48f4a8f8679
begin
	x4_r=x4.+ruido4
	SampleBuf(x4_r,fs)
end 

# ╔═╡ f885d5a3-9a7d-4d6e-bd87-af2c87e42114
md"""
X5:
"""

# ╔═╡ d80800fa-c05a-4d22-97e3-d42b275db34e
begin
	x5_r=x5.+ruido5
	SampleBuf(x5_r,fs)
end 

# ╔═╡ f1023662-9886-403c-ab56-5c07c270bfd0
md"""
#### Señales con ruido en el dominio temporal
"""

# ╔═╡ 2e91672a-7fca-473c-b944-3c5b06582f30
md"""
Se procederá analizando las señales con ruido y comparándolas con las originales.
"""

# ╔═╡ b46de96b-d58b-4f77-80b9-e9bb747bef23
let
	tiempo=range(0,length=length(x1),step=1/fs)
	plot(tiempo, x1_r;
			xlabel="Tiempo [s]",
			label="X1r",
			legendtitle = "Señales",
			title="Señal del microfono uno con y sin ruido"
			)
	plot!(tiempo, x1;
			label="X1"
			)


end

# ╔═╡ 6fdcee1d-b4f6-4cff-9fd4-8ff3de88b8ce
let
	tiempo=range(0,length=length(x1),step=1/fs)
	plot(tiempo, x1_r;
			xlabel="Tiempo [s]",
			ylabel="Señal Xi(t)",
			label="X1r",
			legendtitle = "Señales",
			title="Señales entre tiempos de 1.000 a 1.004 segundos",
			xlim=(1,1.004)
			)
	plot!(tiempo, x1;
			label="X1",
			)

	
end

# ╔═╡ 30ca3aff-7bc8-42b9-8258-d89f92348654
md"""
En las figuras anteriores se puede observar de forma clara el ruido blanco introducido. Ademas se ve que donde es mas destacable el ruido es donde la energia de la señal original es baja, lo cual se utilizara en el ejercicio 7 para reducirlo. 
"""

# ╔═╡ 4129bfc2-e515-4ebf-ab3a-ccdde72c0f20
md"""
#### Señales con ruido en el dominio de la frecuencia
"""

# ╔═╡ 105d6a25-0421-4e87-b5e8-574496dff0e7
md"""
En este inciso se realizara un análisis análogo al ejercicio 1, es decir, Observando la transformada de Fourier y los espectrogramas de la señal con ruido.
"""

# ╔═╡ fda32acf-480a-4f22-8ba5-c1e8a17a536f
let
	
	freq= range(0;stop=fs,length=length(fft(x1_r)))
	plot(freq , 
			abs.(fft(x1_r));
			xlabel="Frecuencia [Hz]",
			ylabel="FFT Xi [dB]",
			title="Espectros de las señales con y sin ruido",
			label = "FFT X1r" ,
			legendtitle = "FFT Xi",
			xlims = (0, fs/2),
			)
	
	plot!(freq , 
			abs.(fft(x1));
			label = "FFT X2",
			)
	


end

# ╔═╡ ecc02872-a022-4740-a15b-75685d0bf330
md"""
Viendo la transformada de Fourier de la señal con y sin ruido se nota que el ruido introducido cumple correctamente las características de un ruido blanco ya que se observa con igual potencia en todas las frecuencias.
"""

# ╔═╡ 3b865b2e-23c4-4a12-a5d7-2b0d49b9cece
let 
	specplot(x1_r;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 1 con ruido",
			fs)
end 

# ╔═╡ 9f0028a8-fcb3-40e2-bd76-8c691c801462
let 
	specplot(x2_r;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 2 con ruido",
			fs)
end 

# ╔═╡ d4071362-ef3f-4890-a84d-5d0d3b0a1580
let 
	specplot(x3_r;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 3 con ruido",
			fs)
end 

# ╔═╡ d0fc4137-dd3f-458f-8c9e-90db111737d9
let 
	specplot(x4_r;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 4 con ruido",
			fs)
end 

# ╔═╡ 9be14c8a-c62d-442f-a1c7-3888e12fc2c4
let 
	specplot(x5_r;
			overlap=0.9,
			onesided=true,
			window=hanning(512),
			title="Espectrograma señal 5 con ruido",
			fs)
end 

# ╔═╡ 5e3dffe8-2058-438b-a2c8-75e5b6bfeec8
md"""
En el espectrograma de las señales lo que se observa es que, con los mismos parametros de la ventana del ejercicio 1, las frecuencias en las cuales la señal poseía una energía baja dejan de ser distinguibles respecto al ruido blanco agregado.
"""

# ╔═╡ 79783530-6d26-406e-944e-f2f74d3d3c7c
md"""
#### Cálculo de los retardos de la señal con ruido
"""

# ╔═╡ dfec1f32-8ed0-4b90-9824-916f38e1257b
md"""
Nuevamente, y a lo largo de todo el trabajo, se calcularán los retardos de forma análoga al **Ejercicio 4** de forma de poder tener distintos métodos para encontrar los retardos y poder compararlos.
"""

# ╔═╡ bc1d24c6-04d0-4d72-84de-177b5a94916c
md"""
##### Cálculo mediante correlación temporal
"""

# ╔═╡ 2bff938e-24a0-4ad0-bf51-17f92a3a3967
begin 
	corr_x21r = xcorr(x2_r,x1_r) 
	corr_x32r = xcorr(x3_r,x2_r) 
	corr_x43r = xcorr(x4_r,x3_r) 
	corr_x54r = xcorr(x5_r,x4_r) 
end ;

# ╔═╡ c0d1c0d9-7113-490d-8ede-e939a832f15f
ret_x21r_temporal=hallar_retardo_temp(corr_x21r,fs)- length(x1_r)/fs

# ╔═╡ 55d3d834-1ee7-415f-807d-a4d11f21a45f
ret_x32r_temporal=hallar_retardo_temp(corr_x32r,fs)- length(x2_r)/fs

# ╔═╡ 97f5ae86-3140-47aa-a414-123183ad6c1f
ret_x43r_temporal=hallar_retardo_temp(corr_x43r,fs)- length(x3_r)/fs

# ╔═╡ 4b2bec95-10bd-4999-8cec-dd006238ef90
ret_x54r_temporal=hallar_retardo_temp(corr_x54r,fs)- length(x4_r)/fs

# ╔═╡ 9590b989-397a-4134-8295-e85d617a04f3
md"""
##### Cálculo de los retardos mediante Gph
"""

# ╔═╡ d48e6c17-316a-4645-8eda-8d16937fe088
begin
	gph_x21r=calculo_gph(fft(x2_r),fft(x1_r))
	gph_x32r=calculo_gph(fft(x3_r),fft(x2_r))
	gph_x43r=calculo_gph(fft(x4_r),fft(x3_r))
	gph_x54r=calculo_gph(fft(x5_r),fft(x4_r))
end;

# ╔═╡ 20195a24-a17d-41ed-851c-750a85987750
ret_x21_gphr=hallar_retardo_f(gph_x21r,fs)

# ╔═╡ 533c9c63-43e9-4850-9d64-1a2cf430b4b8
ret_x32_gphr=hallar_retardo_f(gph_x32r,fs)

# ╔═╡ 8889bc90-3936-4f8a-8708-6978239e4d74
ret_x43_gphr=hallar_retardo_f(gph_x43r,fs)

# ╔═╡ 06cf8a4b-0042-4861-8ca3-11ae854e645c
ret_x54_gphr=hallar_retardo_f(gph_x54r,fs)

# ╔═╡ caf3cc1e-344e-415f-bbe5-899a40364ec4
md"""
Los retardos son equivalentes a los calculados con las señales sin ruido, lo cual se puede entender nuevamente pensando en la poca precisión que se obtiene al trabajar con las señales sin un procesamiento previo como puede ser el de sobremuestreo de la señal.
"""

# ╔═╡ 40113269-c56c-43fe-ae0a-4f1b9a07ede8
md"""
#####  Cálculo apartir de la evolución temporal de los retardos
"""

# ╔═╡ a5b9da6b-b033-4176-9d03-b7d5658561fb
N2=N1

# ╔═╡ 37f43170-9576-4f36-b750-308415e36b66
delta_n2= delta_n1

# ╔═╡ e25c4ecb-df77-4c33-88ec-466c400dbf19
begin
	evtemp_ret21r=ev_temp(N2,delta_n2,x1_r,x2_r,fs)
	evtemp_ret32r=ev_temp(N2,delta_n2,x2_r,x3_r,fs)
	evtemp_ret43r=ev_temp(N2,delta_n2,x3_r,x4_r,fs)
	evtemp_ret54r=ev_temp(N2,delta_n2,x4_r,x5_r,fs)
end ;

# ╔═╡ aefa8119-4408-4343-a351-e71292e900bb
let 
	tiempo=range(0,length=length(evtemp_ret21r),stop=length(x1_r)/fs)

	plot(plot(tiempo, evtemp_ret21r;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X2-X1",
		
			)
		, plot(tiempo, evtemp_ret32r;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X3-X2",
			
			),
		plot(tiempo, evtemp_ret43r;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X4-X3",
			
			),
		plot(tiempo, evtemp_ret54r;
			xlabel="Tiempo [s]",
			ylabel="Retardo",
			title="Retardo X5-X4",
			
			) 
		
		)
end 

# ╔═╡ b9dca6e4-254b-4b94-91ba-6f016084229b
md"""
Se observa que introduciendo el ruido se genera una distorsión en los retardos que aumenta mucho en los tiempos donde la señal tiene una energía comparable al ruido (cuando la persona no se encuentra hablando). 
"""

# ╔═╡ 774508d2-ed29-445c-b758-671d89b4a0ff
ret_x21r_prom=median(evtemp_ret21r)

# ╔═╡ ae9cb4d5-6681-4a44-9c29-a9cf989c3ae7
ret_x32r_prom=median(evtemp_ret32r)

# ╔═╡ 0b382099-9142-4711-ba5e-c8c2606c02a6
ret_x43r_prom=median(evtemp_ret43r)

# ╔═╡ b6900f4d-5025-41b1-97f2-bd497d8269a2
ret_x54r_prom=median(evtemp_ret54r)

# ╔═╡ f7e185b1-0a43-4668-bd66-4c010e778979
md"""
#### Estimación de la posición de la fuente de la señal con ruido
"""

# ╔═╡ edf382d9-8ee2-4266-8ac5-9f41d4478885
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	recta1= recta(ret_x21_temporal,2+d,1,x)
	recta2= recta(ret_x32_temporal+ret_x21_temporal,2+2*d,1,x)
	recta3= recta(ret_x43_temporal+ret_x32_temporal+ret_x21_temporal,2+3*d,1,x)
	recta4=      recta(ret_x54_temporal+ret_x43_temporal+ret_x32_temporal+ret_x21_temporal,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 6b156a3e-3f52-40cf-b68c-d85160b2a982
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_gphr,2+d,1,x)
	recta2= recta(ret_x32_gphr+ret_x21_gphr,2+2*d,1,x)
	recta3= recta(ret_x43_gphr+ret_x32_gphr+ret_x21_gphr,2+3*d,1,x)
	recta4= recta(ret_x54_gphr+ret_x43_gphr+ret_x32_gphr+ret_x21_gphr,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente con Gph",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ c36023ae-142b-42fa-851b-6aef176d2e47
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21r_prom,2+d,1,x)
	recta2= recta(ret_x32r_prom+ret_x21r_prom,2+2*d,1,x)
	recta3= recta(ret_x43r_prom+ret_x32r_prom+ret_x21r_prom,2+3*d,1,x)
	recta4= recta(ret_x54r_prom+ret_x43r_prom+ret_x32r_prom+ret_x21r_prom,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 16c19fe5-010a-4b9b-8de8-46ec0ce211a9
md"""
Se observa que si bien introducir ruido puede generar una peor aproximación de la posición de la fuente, en este caso, no es tan notable ya que al tener pocas muestras, y por lo tanto poca precisión, la estimación es muy aproximada y en muchos casos el ruido no modifica el valor de los retardos. 
"""

# ╔═╡ a0ae3f60-780b-421f-a241-9b0cbc885ab4
md"""
## Ejercicio 6

!!! info "Sobremuestrear y repetir estimación"
	Modificar el algoritmo de estimación de los retardos realizando un sobremuestreo de las señales $IDFT(G_{PH}[k])$. Repetir los ejercicios 2 y 4.
"""

# ╔═╡ 7913d114-0669-44e1-a046-5d98a8ea75f3
md"""

Una de las limitaciones del algoritmo propuesto, como se ha mencionado previamente, es su carácter discreto acotando la resolución
temporal/espacial, como se puede observar en la Figura 5 .b) y se ve reflejado en la Figura 6 . Una alternativa
para mitigar esta limitación es realizar un sobremuestreo de IDFT(G PH [k]) antes de estimar su máximo.
"""

# ╔═╡ e9ed99e4-bec6-46da-80f3-e5714b20aef2
md"""
Para realizar el sobremuestreo de la señal se utilizó un esquema como se ve a contiación; 
"""

# ╔═╡ 3f362919-6099-4eb1-ba2a-849d9c87989d
md"""
$(LocalResource(joinpath("resources", "img", "sobremuestreo.jpeg")))
"""

# ╔═╡ d9a7b0c2-f5b9-4529-9264-61bb813d537f
md"""
El procedimiento a seguir es expandir la señal original en un factor L agregando ceros entre muestras y, luego, conectar en cascada un filtro pasa bajos para eliminar las copias de la señal que aparecen en el domiño de las frecuencias. 
"""

# ╔═╡ 508c1cd2-c237-415c-a7b5-e87f0187074d
md"""
**Definición del factor de sobremuestreo**
"""

# ╔═╡ fea4f834-86af-4377-9c34-e03de242f76d
L=10

# ╔═╡ 119f5de8-b783-4486-bc7e-29b9c3d69181
md"""
**Filtrado de bajas frecuencias** 
"""

# ╔═╡ a7b3b398-7ecf-4602-b070-9f746dbb8c72
md"""
Para la implementación del filtro pasa bajas discreto se comenzará planteando un filtro cuadrado ideal en frecuencia como el que se ve en la figura, que en tiempo corresponde a una función Sinc. Luego, para que tenga una forma finita y poder trabajar con él de forma computacional se lo multiplicara por una ventana en tiempo de forma de quedarse con la mayor parte de energía del filtro. Por último, se utilizara la función "conv" para realizar la convolución entre la señal sobre muestreada y el filtro generado. 
"""

# ╔═╡ 0f693496-915f-41bd-9109-14d345a9a8c4
begin 
	  orden = 101
      h_ideal(n) = 1/L * sinc(n/L) *L
      ns = range(-(orden - 1) / 2; length=orden)
      ventana = hanning(orden) 
      filtro_lp = h_ideal.(ns) .* ventana
end ;

# ╔═╡ d31af6b1-2ac0-437e-9fb1-35d10be8643b
function filtrado(xsm)
   filtrado = conv(xsm, filtro_lp)
end

# ╔═╡ b9a99a9e-da30-42c9-b1a6-c037753d800a
let 
	  #freq= range(-fs/2;stop=fs/2,length=length(hs))
	  ns= range(-pi, stop=pi, length=length(filtro_lp))
	  plot(ns, fftshift(abs.(fft(filtro_lp))); 
		title="Filtro Pasa bajos" ,
		xlabel="Ω",
		label="pasa bajos",
		ylabel="|H(Ω)|" )
end 

# ╔═╡ 88b00919-59bd-44da-b7e4-5e44e5553ec3
md"""
#### Señales originales sobremuestreadas
"""

# ╔═╡ 31e8ea41-7448-484c-a4a6-ff66bc613d74
md"""
**Definición de las señales sobremuestreadas**
"""

# ╔═╡ a12f62a3-cbee-4feb-8307-f966047f1734
x1sm=filtrado(upsample(x1,L))

# ╔═╡ 2b8b7868-4a6f-475f-b964-8457ffa42c6f
x2sm=filtrado(upsample(x2,L))

# ╔═╡ ea533eae-a753-4921-b99d-68e1baf0f396
x3sm=filtrado(upsample(x3,L))

# ╔═╡ 5e68d2e3-03d2-4310-8085-8979bff3d459
x4sm=filtrado(upsample(x4,L))

# ╔═╡ 4e398fec-0b0f-410a-a7b7-d4ad3f4f097c
x5sm=filtrado(upsample(x5,L))

# ╔═╡ d74b4ab0-e51a-4e69-92be-23b48b24d4cb
md"""
##### Cálculo de los retardos
"""

# ╔═╡ b4e71eb6-0530-43b2-b746-10b487acec75
md"""
**Cálculo mediante la correlación temporal**
"""

# ╔═╡ 120892eb-83fe-430a-8bd0-20cd2b66f88c
begin
	corr_x21sm=xcorr(x2sm,x1sm)
	corr_x32sm=xcorr(x3sm,x2sm)
	corr_x43sm=xcorr(x4sm,x3sm)
	corr_x54sm=xcorr(x5sm,x4sm)
end ;

# ╔═╡ 6bddbbbe-560f-4993-a20b-08fc9f9b78c4
ret_x21sm_temp=hallar_retardo_temp(corr_x21sm,fs*L)- length(x1sm)/(fs*L)

# ╔═╡ 8272acb0-402e-48d0-a94c-3814a4c9590e
ret_x32sm_temp=hallar_retardo_temp(corr_x32sm,fs*L)- length(x2sm)/(fs*L)

# ╔═╡ c4ce8591-38f6-4592-9321-c7df9ffe444f
ret_x43sm_temp=hallar_retardo_temp(corr_x43sm,fs*L)- length(x3sm)/(fs*L)

# ╔═╡ 6baea40d-0b53-4c21-b4fb-df2bd91bc023
ret_x54sm_temp=hallar_retardo_temp(corr_x54sm,fs*L)- length(x4sm)/(fs*L)

# ╔═╡ 41e96a0e-2988-4c8a-b5fa-dcf9da074cd7
md"""
**Cálculo de los retardos mediante IDFT GCC-PATH de la señal con ruido**
"""

# ╔═╡ 53cd8588-e646-47b1-ad1c-76524d636fe1
begin
	fft_x1sm=fft(x1sm)
	fft_x2sm=fft(x2sm)
	fft_x3sm=fft(x3sm)
	fft_x4sm=fft(x4sm)
	fft_x5sm=fft(x5sm)
	
	gph_x21sm=calculo_gph(fft_x2sm,fft_x1sm)
	gph_x32sm=calculo_gph(fft_x3sm,fft_x2sm)
	gph_x43sm=calculo_gph(fft_x4sm,fft_x3sm)
	gph_x54sm=calculo_gph(fft_x5sm,fft_x4sm)
end ;

# ╔═╡ 40690521-dfc1-4aac-9560-ef8139a60de3
let
	
	tiempo=range(0,length=length(x1sm),step=1/(fs*L))
	plot(tiempo,(gph_x21sm);
		title="Correlación de señales mediante GCC-PATH",
		xlims=(0,0.0003),
		legendtitle="Correlación señal Xi-Xj",
		label="corr (x2-x1)",
		ylabel="gph(xi,xj)",
		xlabel= "Tiempo [s]"
	)
	plot!(tiempo,(gph_x32sm);
		label="corr (x3-x2)"
	)
	plot!(tiempo,(gph_x43sm);
		label="corr (x4-x3)"
	)
	plot!(tiempo,(gph_x54sm);
		label="corr (x5-x4)"
	)

end

# ╔═╡ 66484379-c718-44b5-b5d5-6d5411bd3a08
md"""
El efecto del sobremuestreo en el cálculo de la correlación de señales mediante GCC-PATH se puede observar gráficamente, se ve que sobremuestreando la señal, el grafico de la correlación es mucho más suave y, al tener más muestras, más preciso.
"""

# ╔═╡ f82b901d-b7c7-4d7a-91bd-6d645fb957eb
ret_x21_sm=hallar_retardo_f(gph_x21sm,fs*L)

# ╔═╡ 0fe505b9-687d-45ce-a27f-a66918a00891
ret_x32_sm=hallar_retardo_f(gph_x32sm,fs*L)

# ╔═╡ 9e1d4450-e929-4516-ac89-8f8e5e886e3f
ret_x43_sm=hallar_retardo_f(gph_x43sm,fs*L)

# ╔═╡ ab8baba6-8617-4c9e-9fd2-aaf5e1224eb6
ret_x54_sm=hallar_retardo_f(gph_x54sm,fs*L)

# ╔═╡ c3e01594-911a-49f0-8271-29f0dc75d9c0
md"""
**Cálculo mediante la evolución temporal de los retardos**
"""

# ╔═╡ 4a1ac7d1-5ec1-491a-a0cb-454abd52d195
md"""
Para mantener constante la ventana en el dominio temporal hay que multiplicar la cantidad de puntos por el factor de sobremuestreo de forma de mantener la relacion muestras-frecuencia de muestreo.
"""

# ╔═╡ a823b064-d2dc-4128-8aea-763d59f75639
N3=N1*L

# ╔═╡ c700e207-aabd-49e9-a3e1-c70f2b7b5adb
delta_n3=delta_n1*L

# ╔═╡ 151e5b21-8e3c-434e-8b23-c33453553d83
begin
	evtemp_ret21sm=ev_temp(N3,delta_n3,x1sm,x2sm,fs*L)
	evtemp_ret32sm=ev_temp(N3,delta_n3,x2sm,x3sm,fs*L)
	evtemp_ret43sm=ev_temp(N3,delta_n3,x3sm,x4sm,fs*L)
	evtemp_ret54sm=ev_temp(N3,delta_n3,x4sm,x5sm,fs*L)
end ;

# ╔═╡ 0df73c2c-2a9e-4692-9f1c-efe851bcea84
ret_x21sm_prom=median(evtemp_ret21sm)

# ╔═╡ 2b158ebc-fa98-47d0-8e30-3a9244e55b49
ret_x32sm_prom=median(evtemp_ret32sm)

# ╔═╡ 2eb38ae7-f36f-4a60-9282-713a34caad43
ret_x43sm_prom=median(evtemp_ret43sm)

# ╔═╡ 14dc0be9-59a7-47b5-b4e8-d853e2b084ed
ret_x54sm_prom=median(evtemp_ret54sm)

# ╔═╡ 3155855e-6a19-4b38-a580-5d31024bc609
md"""
##### Estimación de la posición de la fuente 
"""

# ╔═╡ a8d0b5b6-bb9a-4550-92c1-89cb37e53307
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21sm_temp,2+d,1,x)
	recta2= recta(ret_x32sm_temp+ret_x21sm_temp,2+2*d,1,x)
	recta3= recta(ret_x43sm_temp+ret_x32sm_temp+ret_x21sm_temp,2+3*d,1,x)
	recta4=      recta(ret_x54sm_temp+ret_x43sm_temp+ret_x32sm_temp+ret_x21sm_temp,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ b4be2d3f-d696-4a93-a3ba-ad6e4ceb1e30
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_sm,2+d,1,x)
	recta2= recta(ret_x32_sm+ret_x21_sm,2+2*d,1,x)
	recta3= recta(ret_x43_sm+ret_x32_sm+ret_x21_sm,2+3*d,1,x)
	recta4= recta(ret_x54_sm+ret_x43_sm+ret_x32_sm+ret_x21_sm,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente con Gph",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 17c31da7-1cea-41d8-a208-f041e88ba843
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21sm_prom,2+d,1,x)
	recta2= recta(ret_x32sm_prom+ret_x21sm_prom,2+2*d,1,x)
	recta3= recta(ret_x43sm_prom+ret_x32sm_prom+ret_x21sm_prom,2+3*d,1,x)
	recta4= recta(ret_x54sm_prom+ret_x43sm_prom+ret_x32sm_prom+ret_x21sm_prom,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 9f40bd2d-dd4e-4612-815b-afe3cdd9c8bb
md"""
Se puede observar que sobremuestrear la señal ayuda en gran medida a la estimación de la posición de la fuente. En este caso, al sobremuestrear con un factor de L, la distancia entre dos muestras sucesivas disminuye en el mismo factor y, por lo tanto, se obtiene la mejoría en la aproximación. Se observa que en la gráfica de estimación de la posición de la fuente con Gph da como resultado un cruce de las cuatro rectas que puede entenderse como una posible posición de la fuente.
"""

# ╔═╡ db516f63-0390-4b62-837a-caebf65a5819
md"""
#### Señales con ruido sobremuestreadas
"""

# ╔═╡ 02945b7e-a6a9-4c10-bfeb-332c4af4ea3f
md"""
En este inciso se realizara el mismo procedimiento del punto anterior pero con las señales con ruido sobremuestreadas. 
"""

# ╔═╡ 88884202-9a02-4103-ad39-19d647d41c15
x1rsm=filtrado(upsample(x1_r,L))

# ╔═╡ 2f0cedfe-75d6-41fa-bf09-fda9d58e6442
x2rsm=filtrado(upsample(x2_r,L))

# ╔═╡ 5fd47b3a-9157-48cd-affe-5652f6885e2b
x3rsm=filtrado(upsample(x3_r,L))

# ╔═╡ 6df26d00-5044-4730-911a-122017cba985
x4rsm=filtrado(upsample(x4_r,L))

# ╔═╡ b6ab03fe-1122-4573-a751-2fc67d4ba765
x5rsm=filtrado(upsample(x5_r,L))

# ╔═╡ 18ad4bac-02ba-4c1b-a1d1-d050370a73e5
md"""
##### Cálculo de los retardos
"""

# ╔═╡ 6b358c2d-8693-453c-842f-21dc8c17b0ab
md"""
**Cálculo mediante la correlación temporal**
"""

# ╔═╡ 52ac97ae-c834-4120-a891-36bfca292f0f
begin
	corr_x21rsm=xcorr(x2rsm,x1rsm)
	corr_x32rsm=xcorr(x3rsm,x2rsm)
	corr_x43rsm=xcorr(x4rsm,x3rsm)
	corr_x54rsm=xcorr(x5rsm,x4rsm)
end ;

# ╔═╡ 48249527-dc7c-4498-9829-b47db1e432de
ret_x21rsm_temp=hallar_retardo_temp(corr_x21rsm,fs*L)- length(x1rsm)/(fs*L)

# ╔═╡ 658bf76a-90b5-461b-962b-3029de315917
ret_x32rsm_temp=hallar_retardo_temp(corr_x32rsm,fs*L)- length(x2rsm)/(fs*L)

# ╔═╡ 9e5ccd51-dc5b-453b-9cf7-cc0f6c7f52e7
ret_x43rsm_temp=hallar_retardo_temp(corr_x43rsm,fs*L)- length(x3rsm)/(fs*L)

# ╔═╡ a288098c-796e-4514-abf0-de68795f0b36
ret_x54rsm_temp=hallar_retardo_temp(corr_x54rsm,fs*L)- length(x4rsm)/(fs*L)

# ╔═╡ aa2a8176-5a1b-4587-9a0b-499e81d7c5e6
md"""
**Cálculo de los retardos mediante IDFT GCC-PATH de la señal con ruido**
"""

# ╔═╡ c19fcee9-aab5-44c0-a733-e0856e7717d9
begin
	fft_x1rsm=fft(x1rsm)
	fft_x2rsm=fft(x2rsm)
	fft_x3rsm=fft(x3rsm)
	fft_x4rsm=fft(x4rsm)
	fft_x5rsm=fft(x5rsm)
	
	gph_x21rsm=calculo_gph(fft_x2rsm,fft_x1rsm)
	gph_x32rsm=calculo_gph(fft_x3rsm,fft_x2rsm)
	gph_x43rsm=calculo_gph(fft_x4rsm,fft_x3rsm)
	gph_x54rsm=calculo_gph(fft_x5rsm,fft_x4rsm)
end ;

# ╔═╡ f89a11e1-421a-416f-9913-936dfd51baa3
ret_x21_rsm=hallar_retardo_f(gph_x21rsm,fs*L)

# ╔═╡ 87d51648-dd34-4be5-984d-98ccba3f94a2
ret_x32_rsm=hallar_retardo_f(gph_x32rsm,fs*L)

# ╔═╡ 14be827f-feff-4531-a7de-5ef7fae10ed7
ret_x43_rsm=hallar_retardo_f(gph_x43rsm,fs*L)

# ╔═╡ 6ff9978e-8493-416c-84b2-4427542adf27
ret_x54_rsm=hallar_retardo_f(gph_x54rsm,fs*L)

# ╔═╡ 0fe33cd1-93b0-4556-9a29-f110349f3263
md"""
**Cálculo mediante la evolución temporal de los retardos**
"""

# ╔═╡ b75a210f-aaf5-46d8-ac73-cdc2827d8a02
begin
	evtemp_ret21rsm=ev_temp(N3,delta_n3,x1rsm,x2rsm,fs*L)
	evtemp_ret32rsm=ev_temp(N3,delta_n3,x2rsm,x3rsm,fs*L)
	evtemp_ret43rsm=ev_temp(N3,delta_n3,x3rsm,x4rsm,fs*L)
	evtemp_ret54rsm=ev_temp(N3,delta_n3,x4rsm,x5rsm,fs*L)
end ;

# ╔═╡ 3c09ad96-4c26-49ec-a6a4-52e245c2c631
ret_x21rsm_prom=median(evtemp_ret21rsm)

# ╔═╡ 1ad200a2-cada-4c67-8c50-b20015453a57
ret_x32rsm_prom=median(evtemp_ret32rsm)

# ╔═╡ 00c2fa34-dd6c-4a53-95f2-54ea8520271c
ret_x43rsm_prom=median(evtemp_ret43rsm)

# ╔═╡ b51b3ec0-5c69-41dc-aed9-20646f93a05c
ret_x54rsm_prom=median(evtemp_ret54rsm)

# ╔═╡ 9ef8c221-3200-4932-8b4a-79e94c806dec
md"""
##### Estimación de la posición de la fuente 
"""

# ╔═╡ 69104691-3c57-427e-8992-9f42c75b9a31
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21rsm_temp,2+d,1,x)
	recta2= recta(ret_x32rsm_temp+ret_x21rsm_temp,2+2*d,1,x)
	recta3= recta(ret_x43rsm_temp+ret_x32rsm_temp+ret_x21rsm_temp,2+3*d,1,x)
	recta4=      recta(ret_x54rsm_temp+ret_x43rsm_temp+ret_x32rsm_temp+ret_x21rsm_temp,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ dc2048ca-97a2-4463-8d55-5b6459b52e07
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_rsm,2+d,1,x)
	recta2= recta(ret_x32_rsm+ret_x21_rsm,2+2*d,1,x)
	recta3= recta(ret_x43_rsm+ret_x32_rsm+ret_x21_rsm,2+3*d,1,x)
	recta4= recta(ret_x54_rsm+ret_x43_rsm+ret_x32_rsm+ret_x21_rsm,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente con gph",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ ebe09117-2c47-413b-9903-76fcc3a5a14a
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21rsm_prom,2+d,1,x)
	recta2= recta(ret_x32rsm_prom+ret_x21rsm_prom,2+2*d,1,x)
	recta3= recta(ret_x43rsm_prom+ret_x32rsm_prom+ret_x21rsm_prom,2+3*d,1,x)
	recta4= recta(ret_x54rsm_prom+ret_x43rsm_prom+ret_x32rsm_prom+ret_x21rsm_prom,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 43396f61-9d0c-4a4e-8e4e-dc8e86d9578b
md"""
En este punto, una vez sobremuestreada la función, si se puede observar como modifica el ruido el calculo de la estimación de la posición de la fuente. Se ve que al incluir ruido, los retardos tienen un valor diferente al de la señal sin ruido y, por lo tanto, la fuente da en una diferencia posición. 
"""

# ╔═╡ 392ca647-47b2-43e7-b3aa-d549db7a2387
md"""
## Ejercicio 7

!!! info "Incorporar filtrado pasabandas"
	Utilizando los espectros obtenidos en el ejercicio 5, diseñar un filtro pasabanda con el objetivo de reducir el ruido y por lo tanto mejorar la estimación de los retardos. Graficar la respuesta en frecuencia y diagrama de polos y ceros del filtro obtenido. Repetir los ejercicios 2 y 4.
"""


# ╔═╡ e2c91eba-6db8-46aa-89f3-bc1872f82e10
md"""

Si tenemos más de una fuente, por ejemplo un locutor y ruido de fondo, con diferentes distribuciones de
energía en su espectro de frecuencias, podemos reducir el ancho de banda a analizar al de la fuente de
interés, reduciendo los errores de cálculo.
"""

# ╔═╡ ad03d129-9304-4075-aff2-01d0ad0c6d62
md"""
Con este objetivo, se diseñó un filtro pasa banda que atenúa las frecuencias entre $f_l$ y $f_h$, las cuales fueron seleccionadas de forma de reducir el ancho de banda al rango donde la señal tenía mayor energía, es decir, los rangos de frecuencias en los cuales emite el locutor.
"""

# ╔═╡ 295bf743-b296-4288-8c1d-b24a6f58d2c0
md"""
#### Definición del filtro pasa banda
"""

# ╔═╡ c23c82c7-e488-482c-85c2-2036c8a4a96c
md"""
Para la implementación del pasabandas el procedimiento fue análogo al del pasabajos, se definió el pasabandas ideal como una cuadrada en espectro que se corresponde a un coseno multiplicado por una Sinc y, luego se lo multiplico por una ventana para poder trabajar con el computacionalmente.
"""

# ╔═╡ 13181a57-9b0f-497a-98a6-30435c0885cc
begin 
	#variando el orden incremento la pendiente de la recta (lo vuelvo mas ideal)
	order = 1001
	winds = hanning(order) 

	h_ideal2(n)= 1/10* sinc(n/10) * cos((121 *π* n)/1200) * 2 # el dos por el 2pi de la 		anti transformada 
	#la sinc me da el ancho del pasa banda
	# el cos me da cuanto lo corro a la derecha 
	
	
	ns2 = range(-(order - 1) / 2; length=order)
	filtro_pb  = h_ideal2.(ns2) .* winds
end ;

# ╔═╡ 6aeb9021-2fd6-4a21-8d2f-a45012562752
function filtrar_pasa_bandas(x) 	
	audio_filtrado=conv(x,filtro_pb)
	return audio_filtrado
end

# ╔═╡ 11d5b082-f469-42f1-9517-bcaf47734755
let
	ns= range(-pi, stop=pi, length=length(filtro_pb))
	#freq= range(-fs/2;stop=fs/2,length=length(hs))
	plot(ns,fftshift(abs.(fft(filtro_pb))),
	xlims=(0,π),
	title="Modulo del filtro Pasa bandas" ,
	xlabel="Ω",
	ylabel="|H(Ω)|" )
	
end

# ╔═╡ 1ee15258-932a-4f3e-8776-304f5259a850
md"""
El filtro obtenido atenúa las frecuencias menores a $100\ Hz$ y mayores a $4750 Hz$, que se corresponde a las frecuencias donde la señal de la voz tiene menor energía como ya se ha analizado previamente.  Se observa que la atenuacion no es total para las frecuencias fuera de la banda ya que el filtro no es ideal, y posee en una pendiente que no es infinita en sus flancos positivos y negativos. 
"""

# ╔═╡ ffefb15d-e2bf-4dc3-97a5-15dfc3b2d40a
let 
	freq= range(-pi, stop=pi, length = 10000)
    plot(freq, fftshift(unwrap(angle.(fft(padright(filtro_pb,10000)));round=pi)); 
    label="filtro pasa banda", 
    xlabel="Ω", 
    ylabel="Φ",
    title="Fase del filtro pasa banda"
  )
end

# ╔═╡ 4599fce5-a10e-4072-89de-b53de241d715
md"""
En cuanto a la fase se ve que, como se esperaba, la banda de frecuencias que deja pasar el filtro tiene un desfasaje lineal con algunas imperfecciones generadas por el ventaneo. 
"""

# ╔═╡ f5904749-df66-4261-b36c-fd1eb7c274e1
let
	audio=filtrar_pasa_bandas(x1_r)
	freq= range(0;stop=fs,length=length(audio))
	plot(freq,abs.(fft(audio)),xlims=(0,6000),
	ylabel="FFT [dB]",
	title="Espectros de la señal X1 filtrada",
	)
end

# ╔═╡ 5a9f51f3-1f9c-41ab-bd94-62ea43c38dfb
md"""
Como se puede observar del espectro de la señal del micrófono uno filtrada, el filtro pasa bandas esta atenuando de manera correcta las frecuencias correspondientes, y por lo tanto, disminuyendo el ruido.
"""

# ╔═╡ 063ac4e4-2b5f-44a3-8ede-d6e6372934d9
md"""
##### Polos y ceros del filtro pasa banda
"""

# ╔═╡ 4bbc1821-6137-41a0-ad88-47427589faad
polynomialratio(zpg) = DSP.PolynomialRatio(zpg)

# ╔═╡ b5a84c65-695e-490d-b611-020d34167b1d
getzeros(zpg) = DSP.ZeroPoleGain(zpg).z

# ╔═╡ 8f60a6b4-51b4-492d-8adc-8baa25e50b0f
getpoles(zpg) = DSP.ZeroPoleGain(zpg).p

# ╔═╡ 353383ca-c506-4680-ab58-e72a2fedc2b3
md"""
El filtro diseñado se conoce como un filtro FIR, es decir, que tiene respuesta al impulso finita, por lo cual, el mismo puede ser descripto por una ecuación en diferencias. Esta característica hace que sea posible expresar su transferencia como un cociente de polinomios y de esta forma hallar sus ceros y polos buscando las raices de el nominador y denominador respectivamente, como se muestra a continuación.
"""

# ╔═╡ 49640e3e-ee91-4db8-95c1-e8cf68d11b97
let
	H = PolynomialRatio(filtro_pb, [1])	
	zplane(getzeros(H), getpoles(H);
		xlims=(-2,2),
		title="Diagrama de polos y ceros",
		unitcircle=true)
end

# ╔═╡ 7bac0fd2-2169-4ff2-a6d8-26c06e467b06
md"""
Se nota en el diagrama que el filtro tiene una aparente carencia de polos. Por otro lado, en la distribución de ceros vemos que se encuentran una gran cantidad sobre el circulo unidad que corresponden con aquellas frecuencias que se buscan eliminar que resultan ser las bajas ( cercanas al 0 en el eje Y y 1 en el eje X) y las altas (cercanas a Y=0 y x=-1). También se ve que los ceros aparecen como pares complejos conjugados lo cual tiene sentido debido a que los coeficientes del sistema son reales.
"""

# ╔═╡ 11142c3c-c6be-481e-8c47-e823b9222374
md"""
#### Señales con ruido, sobremuestreadas y filtradas
"""

# ╔═╡ e689b3e5-2b24-4927-9944-5b05e9342668
md"""
X1 filtrada: 
"""

# ╔═╡ f6708135-302a-495d-baec-64400245c50f
begin
	x1frsm= filtrado(upsample(filtrar_pasa_bandas(x1_r),L))
	SampleBuf(x1frsm,fs*L)
end 

# ╔═╡ 0f30a07c-9cf1-4530-a64d-0ba725eda66a
md"""
X2 filtrada:
"""

# ╔═╡ 664b2755-b215-488f-9166-22b981913b68
begin
	x2frsm= filtrado(upsample(filtrar_pasa_bandas(x2_r),L))
	SampleBuf(x2frsm,fs*L)
end 

# ╔═╡ 1e26e8e7-616c-4c65-bf9a-cae7c62b43ba
md"""
X3 filtrada:
"""

# ╔═╡ 43d350b4-78ae-45d0-9942-4061f3f91ef4
begin
	x3frsm=  filtrado(upsample(filtrar_pasa_bandas(x3_r),L))
	SampleBuf(x3frsm,fs*L)
end 

# ╔═╡ a23b9352-5841-42c2-8917-35dff7478097
md"""
X4 filtrada: 
"""

# ╔═╡ cd369522-87fd-4e6b-ae38-d95a186db603
begin
	x4frsm=  filtrado(upsample(filtrar_pasa_bandas(x4_r),L))
	SampleBuf(x4frsm,fs*L)
end 

# ╔═╡ 79a61a00-f228-4217-873f-b4d76a83105d
md"""
X5 filtrada:
"""

# ╔═╡ 58605eb8-da2b-433d-ac6f-61c6d5dde804
begin
	x5frsm=  filtrado(upsample(filtrar_pasa_bandas(x5_r),L))
	SampleBuf(x5frsm,fs*L)
end 

# ╔═╡ 98275258-cb78-4302-9dfe-26d2bb2a982c
md"""
Se puede apreciar que es notable la reducción del ruido blanco lograda al filtrar la señal en el pasa banda. 
"""

# ╔═╡ cf567823-9b52-4a04-b606-bbab6e0f78c0
md"""
#### Cálculo del retardo de la señal con ruido filtrada
"""

# ╔═╡ 44cafae7-2293-44ea-a865-4331b007a26e
md"""
##### Cálculo con los retardos calculados mediante la correlación temporal
"""

# ╔═╡ 5d531437-f2a9-491e-96de-ceb1b77c12d3
begin
	corr_x21frsm=xcorr(x2frsm,x1frsm)
	corr_x32frsm=xcorr(x3frsm,x2frsm)
	corr_x43frsm=xcorr(x4frsm,x3frsm)
	corr_x54frsm=xcorr(x5frsm,x4frsm)
end ;

# ╔═╡ 0a9cda03-2e2b-4792-9798-917eaab1cb65
ret_x21frsm_temp=hallar_retardo_temp(corr_x21frsm,fs*L)- length(x1frsm)/(fs*L)

# ╔═╡ 3dffbdef-3984-453d-a7da-24f0ce24a777
ret_x32frsm_temp=hallar_retardo_temp(corr_x32frsm,fs*L)- length(x2frsm)/(fs*L)

# ╔═╡ 99fdd233-d996-4635-9c4b-c9dd6b538881
ret_x43frsm_temp=hallar_retardo_temp(corr_x43frsm,fs*L)- length(x3frsm)/(fs*L)

# ╔═╡ 48a82e31-7cd1-4404-a94c-e7e0a8f18eba
ret_x54frsm_temp=hallar_retardo_temp(corr_x54frsm,fs*L)- length(x4frsm)/(fs*L)

# ╔═╡ 50114082-d794-42c8-bf78-0ab985a2c373
md"""
##### Cálculo de los retardos mediante IDFT GCC-PATH de la señal con ruido
"""

# ╔═╡ 58274f26-2679-4a17-ada7-74f697b8bb2f
begin
	fft_x1frsm=fft(filtrado(x1frsm))
	fft_x2frsm=fft(filtrado(x2frsm))
	fft_x3frsm=fft(filtrado(x3frsm))
	fft_x4frsm=fft(filtrado(x4frsm))
	fft_x5frsm=fft(filtrado(x5frsm))
	
	gph_x21frsm=calculo_gph(fft_x2frsm,fft_x1frsm)
	gph_x32frsm=calculo_gph(fft_x3frsm,fft_x2frsm)
	gph_x43frsm=calculo_gph(fft_x4frsm,fft_x3frsm)
	gph_x54frsm=calculo_gph(fft_x5frsm,fft_x4frsm)
end ;

# ╔═╡ a2af829f-8979-4ca8-bd6b-2e840de3ac0f
ret_x21_frsm=hallar_retardo_f(gph_x21frsm,fs*L)

# ╔═╡ e1ee9a80-242b-40fb-b7d5-843ef970f78c
ret_x32_frsm=hallar_retardo_f(gph_x32frsm,fs*L)

# ╔═╡ 3ebdc286-f99a-4cc2-b2b2-59ebb3aeb99f
ret_x43_frsm=hallar_retardo_f(gph_x43frsm,fs*L)

# ╔═╡ cd2a85d3-0d94-4d99-89a6-a1073c400e59
ret_x54_frsm=hallar_retardo_f(gph_x54frsm,fs*L)

# ╔═╡ 5be8be44-73be-4b88-903c-ff74244469d6
md"""
##### Cálculo mediante la evolución temporal de los retardos
"""

# ╔═╡ 7362effd-e8d4-4df3-b163-a263860716ff
N4=N1*L

# ╔═╡ 917ae275-d71c-4561-b3f8-a308c5b46ac4
delta_n4= delta_n1*L

# ╔═╡ fb4734d5-c2de-48db-9852-39d32454c8e7
begin
	evtemp_ret21frsm=ev_temp(N4,delta_n4,x1frsm,x2frsm,fs*L)
	evtemp_ret32frsm=ev_temp(N4,delta_n4,x2frsm,x3frsm,fs*L)
	evtemp_ret43frsm=ev_temp(N4,delta_n4,x3frsm,x4frsm,fs*L)
	evtemp_ret54frsm=ev_temp(N4,delta_n4,x4frsm,x5frsm,fs*L)
end ;

# ╔═╡ 54b608ea-b06d-4fb2-bd23-202793a66cb0
ret_x21frsm_prom=median(evtemp_ret21frsm)

# ╔═╡ 3ddc63ef-ce55-4fa3-8245-b0e1ff178334
ret_x32frsm_prom=median(evtemp_ret32frsm)

# ╔═╡ f39bc912-c883-45ee-a828-e8713c514392
ret_x43frsm_prom=median(evtemp_ret43frsm)

# ╔═╡ 9870c04e-b23b-400c-9f22-ac77bd337cd5
ret_x54frsm_prom=median(evtemp_ret54frsm)

# ╔═╡ 30390069-6418-4f5b-b05a-a5da54fd909b
md"""
#### Estimación de la posición de la fuente
"""

# ╔═╡ 274e086e-567b-4669-9c5a-42bc8dbc01a5
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21frsm_temp,2+d,1,x)
	recta2= recta(ret_x32frsm_temp+ret_x21frsm_temp,2+2*d,1,x)
	recta3= recta(ret_x43frsm_temp+ret_x32frsm_temp+ret_x21frsm_temp,2+3*d,1,x)
	recta4=      recta(ret_x54frsm_temp+ret_x43frsm_temp+ret_x32frsm_temp+ret_x21frsm_temp,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 2d32c88f-9b87-44d2-9d6c-4d85d6fb4c0b
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21_frsm,2+d,1,x)
	recta2= recta(ret_x32_frsm+ret_x21_frsm,2+2*d,1,x)
	recta3= recta(ret_x43_frsm+ret_x32_frsm+ret_x21_frsm,2+3*d,1,x)
	recta4= recta(ret_x54_frsm+ret_x43_frsm+ret_x32_frsm+ret_x21_frsm,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la posición de la fuente con gph",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 750a0b81-161f-4c4e-8114-d00b5ead9baa
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1),(2.1,1),(2.15,1),(2.2,1)]
	#x3=range(2+3*d; length=4, step=1)
	recta1= recta(ret_x21frsm_prom,2+d,1,x)
	recta2= recta(ret_x32frsm_prom+ret_x21frsm_prom,2+2*d,1,x)
	recta3= recta(ret_x43frsm_prom+ret_x32frsm_prom+ret_x21frsm_prom,2+3*d,1,x)
	recta4= recta(ret_x54frsm_prom+ret_x43frsm_prom+ret_x32frsm_prom+ret_x21frsm_prom,2+4*d,1,x)
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,recta1; 
		xlims=(0,3) 
		,ylims=(0,4),
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,recta2)
	plot!(x,recta3)
	plot!(x,recta4)
	
end

# ╔═╡ 25af3924-80b2-4138-9888-41c970b09a44
md"""
Se puede apreciar que con el filtro y la reducción de ruido, la estimación de la posición de la fuente tiene una leve mejoria. 
"""

# ╔═╡ d6babe7a-3185-41cd-884c-d48115380e3d
md"""
## Ejercicio 8

!!! info "Alinear señales y escuchar"

	Alinear las señales utilizando los retardos estimados en el ejercicio anterior y obtener una nueva señal promediada (Ec. 13). Escuchar ambas versiones. Tener en cuenta que es necesario sobremuestrear las señales con la misma tasa del ejercicio 6 de modo de obtener una mejor alineación.
"""

# ╔═╡ fe407a65-e90e-4875-9317-6c5aa1742e5a
md"""
---

Una aplicación de los arreglos de micrófonos es mejorar la relación señal ruido de una fuente en particular,
eliminando o atenuando las fuentes secundarias. Una técnica clásica para mejorar el SNR es mediante una
combinación lineal de las señales registradas por cada micrófono, realizando una conformación de haz o
beamforming, donde las perturbaciones indeseadas se atenúan por el fenómeno de selectividad espacial
del arreglo. Para un arreglo de N micrófonos, la señal resultante $ŝ[n]$ se puede expresar como:


```math
\text{Ec 13:\qquad}\hat{s}[n]=\frac 1 N \sum_{i=1}^N s_i[n-d_i] 
```

donde $s_i[n]$ es la señal registrada por el micrófono $i$-ésimo, con retardo de llegada $d_i$.
"""

# ╔═╡ ab24000d-8966-4a9f-b9e1-684e3d2e7df7
#function alinear(xs, retardo, N)
#	s_n = zeros(length(x1))
#	
#	for i in 1:N
#		xss = padright(xs[i], length(xs[i]) + convert(Int64,retardo[i]) -1) 
#		s_n = s_n .+ (xss[convert(Int64, retardo[i]):convert(Int64, length(xs[i]) + retardo[i]) - 1])
#		i = i + 1
#	end
#	return s_n
#end

# ╔═╡ ee3e998d-e370-4fa1-ad66-9ed3d2ced7a0
md"""
En este ítem, para realizar la alineación, se construirá un vector con los retardos y otro con las señales obtenidos en el ejercicio anterior y luego se realizará la convolución circular entre ambos vectores. Por último se tomará un promedio de estas señales.
"""

# ╔═╡ e1de2b1a-505d-4d5e-9e6a-a3e396040105
md"""
Es importante remarcar que la alineación se hara sobre las señales filtradas como lo pide la consigna del proyecto.
"""

# ╔═╡ e39d3963-0916-414a-96df-ea426316509a
md"""
#### Señal alineada
"""

# ╔═╡ c46ba773-77d1-410b-ae24-80c9334673e7
function hallar_retardo_muestra(gph,fs) 
	max_voice_f0 = 500. # Hz
	n_period_min = round(Int, fs / max_voice_f0)

	imax = argmax_edges(gph, n_period_min)

	nlim = length(gph) ÷ 2

	return (mod(imax - 1 + nlim, length(gph)) - nlim)
end

# ╔═╡ e87b668e-1d3a-467d-88ff-84d667eed457
md"""
###### Definición del vector de retardos
"""

# ╔═╡ 90753c41-7c15-4b62-8d0a-aaf82261ccc0
begin 
	ret_x21_frsm_muestra=hallar_retardo_muestra(gph_x21frsm,fs*L)
	ret_x32_frsm_muestra=hallar_retardo_muestra(gph_x32frsm,fs*L)
	ret_x43_frsm_muestra=hallar_retardo_muestra(gph_x43frsm,fs*L)
	ret_x54_frsm_muestra=hallar_retardo_muestra(gph_x54frsm,fs*L)
	
	retardo = [1, 1+ ret_x21_frsm_muestra, 1 + ret_x21_frsm_muestra + 		ret_x32_frsm_muestra,1 + ret_x21_frsm_muestra + ret_x32_frsm_muestra + ret_x43_frsm_muestra , 1 + ret_x21_frsm_muestra + ret_x32_frsm_muestra + ret_x43_frsm_muestra + ret_x54_frsm_muestra]
end 


# ╔═╡ 9983382c-4dc0-4e63-916f-2739b39d6313
md"""
###### Definición del vector que contiene las señales 
"""

# ╔═╡ 53696d50-45eb-4ac1-b536-4559c5ffd701
xs_frsm = [x1frsm, x2frsm, x3frsm, x4frsm, x5frsm]

# ╔═╡ 9e25b504-772f-4b2b-a258-3c7980a0a19a
function alinear(señal,retardo)
	return mean(circshift.(xs_frsm,retardo))
end 

# ╔═╡ 869b61f0-c82a-497c-8f84-aa20b92cbf91
x_alineada = alinear(xs_frsm, retardo)

# ╔═╡ c314dc24-0916-47b4-8a36-21e4d310bb36
let
		tiempo=range(0,length=length(x_alineada),step=1/(fs*L))
		plot(tiempo,x_alineada,
			xlabel="Tiempo [s]",
			ylabel="Señal",
			label="X alineada",
			title="Señales alineada"
			)
end 

# ╔═╡ 36f14035-c0d9-4bda-a864-b08e56ed9736
md"""
Se observa que la señal alineada tiene la misma forma que la señal original a menos de algunos picos angostos que al promediarla reducen su amplitud. Para poder notar de mejor manera la reducción de ruido se limita el valor del eje y en el grafico; Se obtuvo el siguiente resultado.
"""

# ╔═╡ f3bbb9e4-3c2f-4214-abdc-708f661d1da4
let 
	tiempo=range(0,length=length(x_alineada),step=1/(fs*L))
	plot(tiempo,x1frsm,ylims=(-0.01,0.01),	
			xlabel="Tiempo [s]",
			ylabel="Señal",
			label="X filtrada",
			title="Señales alineada"
			)
	plot!(tiempo,x_alineada,
			label="X alineada")
end

# ╔═╡ 2b54482c-cb5f-4343-a793-cf7d192ca1e0
md"""
Se puede realizar un análisis de la reducción de ruido que se espera ver; Sabiendo que la suma de 5 variables aleatorias iid normales, como el caso del ruido, tiene 5 veces la varianza y luego al promediarlas, el desvío baja en 5 y, por lo tanto, la varianza en 25. Se obtiene como resultado que la varianza baja en $\frac{1}{5}$, y como la varianza para este caso equivale a la potencia por lo explicado en el ejercicio 5, se esperaría ver una reducción en potencia de $\frac{1}{5}$ y del desvío en $(\frac{1}{5})^{(1/2)}$. 

En el grafico se observa que la reducción del ruido es notable y se corresponde con la alineación realizada. Escuchando los audios generados de estas dos señales también se pueden notar las diferencias en el ruido.

"""

# ╔═╡ 22db8952-d578-43ee-8a19-2221a40e5014
md"""
Señal filtrada:
"""

# ╔═╡ 4e40ffa4-f40d-4844-8d9e-d40126866f75
SampleBuf(x1frsm,fs*L)

# ╔═╡ 1b1eaeb8-603b-4ddb-904c-538e65eb822a
md"""
Señal alineada: 
"""

# ╔═╡ ee520187-009c-4c66-80b0-e15fdd1c74b2
SampleBuf(x_alineada,fs*L)

# ╔═╡ 7cbbe305-5a60-4e36-b451-d066f52ed84f
md"""
## Ejercicio 9

!!! info "Visualizar efectos del filtrado"
	Graficar los espectrogramas de la señal del micrófono 1, antes y después del filtrado del ejercicio 8. Identificar los efectos del filtrado.
"""

# ╔═╡ 0f849f94-bf55-40f2-a1ca-4ce59a18c09d
md"""
En este ejercicio se analizaran los espectrogramas de la señal filtrada, la señal alineada y la señal que unicamente fue sobremuestreada. Para los tres casos se utilizara una ventana de Hamming de un ancho temporal de $0.0106\ s$. 
"""

# ╔═╡ b23c2fc6-f135-4ce5-8373-44f4ba80a098
let 
	specplot(x1_r;
			overlap=0.5,
			onesided=true,
			window=hamming(512),
			ylims=(0,10e3),
			title="Espectrograma señal con ruido",
			fs) 
end 

# ╔═╡ de4da224-0e26-4f5b-99cc-a0f66d794066
let 
	specplot(x1frsm;
			overlap=0.5,
			onesided=true,
			window=hamming(512*L),
			ylims=(0,10e3),
			title="Espectrograma señal filtrada",
			fs=fs*L)
end 

# ╔═╡ 5b19ac2f-071f-498c-8590-4ae2b5d628d6
let 
	specplot(x_alineada;
			overlap=0.5,
			onesided=true,
			window=hamming(512*L),
		ylims=(0,10e3),
			title="Espectrograma señal filtrada y alineada",
			fs=fs*L) 
end 

# ╔═╡ b1192298-0943-40b1-b395-e75758740a65
md"""
Observando los espectrogramas se pueden identificar los efectos del filtrado y del proceso de beamforming. En primer lugar, se observa la señal con ruido sin ningún tipo de procesamiento previo, donde el ruido se ve claramente y hace que sea difícil distinguir la señal para las frecuencias donde esta tiene poca energía. 
Luego se ven los efectos del filtrado ya que el ruido se atenúa de forma clara para frecuencias donde la señal no tiene contenido útil (mayores a 5KHz) y por último, el beamforming que tiene la capacidad de atenuar ruido en frecuencias donde hay información relevante lo cual no resulta posible por el filtro, pues no existe un proceso de discriminación estadística entre la señal útil y el
ruido distribuido uniformemente. Este ultimo efecto se ve en la oscuridad del rojo que representa el ruido en las frecuencias menores 5 kHz, se observa que en la señal filtrada es mucho mas claro y, por lo tanto, hay menos ruido.

"""

# ╔═╡ 839ccd32-2666-42cb-9064-49c9fed9dfaa
md"""
## Ejercicio 11 (opcional)

!!! info "Aplicar al caso del oído humano: fuente fija"
	Escuche la señal `audio2.wav` donde se simula el comportamiento del oído humano para localizar fuentes de sonido. Determine perceptualmente de qué lado provienen los distintos segmentos de la señal. Utilice el algoritmo de estimación de retardos para confirmar las posiciones.
"""

# ╔═╡ 5430bc97-8dfb-4f21-a560-5b5e62bec6b9
md"""
#### Caso de aplicación I
"""

# ╔═╡ d91ae5ec-4db3-489f-b415-7f84bb409b68
begin
	x_e11, sr_e11, = wavread(joinpath("resources", "data", "audio2.wav"))
	sound(x_e11, sr_e11)
end

# ╔═╡ 74849120-5209-4cb2-8ef5-53989f79b67f
md"""

En este ejercicio se tendrá como objetivo analizar la posible posición de la fuente para el audio2.wav, en el cual se escucha el audio tratado en las secciones anteriores de manera sucesiva, 5 veces en total. En cada caso resulta posible distinguir la región espacial de la cual proviene el audio por una interpretación auditiva de lo que en fondo es el desfasaje temporal de las señales.

"""

# ╔═╡ e4dc54c9-4514-4fb4-9c0c-11c2b1d8c74d
md"""
Se comenzara escuchando el audio y distinguiendo de forma auditiva la posición de la fuente; En este caso solo se pudo distiguir las regiones espaciales **Atrás y a la izquierda** y **Atras y a la derecha**. En el cuadro a continuación se muestran los resultados. 
"""

# ╔═╡ 289a66a9-e5e1-457d-b2a6-68edf250d36a
md"""
$(LocalResource(joinpath("resources", "img", "posicionfuente.png")))
"""

# ╔═╡ 97552660-5ae0-4b56-abf9-991a3e1d651b
md"""
Donde cada subíndice de la "Senal i" corresponde a 499200 muestras o 10,4 segundos, y es cuando la fuente de sonido cambia de posición. 
"""

# ╔═╡ a8b84c71-b0da-4abf-b1df-f52afdbe76ee
md"""
Se procederá graficando y analizando brevemente las señales obtenidas del audio2.wav y luego, se le aplicara los algoritmos implementados en las secciones anteriores para obtener con mejor precisión una idea de donde proviene el sonido.
"""

# ╔═╡ b6945a9c-7488-41de-9b52-508ea2d5bea5
md"""
En primer lugar, se separará la señal del audio "audio2.wav" en dos, correspondientes a cada uno de los micrófonos que registran la señal y luego se las graficara en el eje temporal.
"""

# ╔═╡ 9e388585-e737-4335-bdf8-1a07e26bde48
begin
	micro_1=x_e11[1:convert(Int64,length(x_e11)/2)]
	micro_2=x_e11[convert(Int64,length(x_e11)/2)+1:end]
end;

# ╔═╡ 7191c39c-c80a-492c-a35e-d143b07a5a50
let 
	
	tiempo=range(0,length=length(micro_1),step=1/fs)
	plot(tiempo, micro_1;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señales de los distintos microfonos"
			)
	plot!(tiempo, micro_2;
			label="Microfono 2",
			)

end 

# ╔═╡ 5283ede3-28eb-4fc5-bfe1-31b71d4c937c
md"""
Se observa en el grafico que, como se había analizado, la señal completa corresponde a la misma señal repetida 5 veces con distintos desfasajes en los micrófonos debido al movimiento de la fuente. 
Es importante remarcar que al tener solo dos micrófonos se tiene como resultado un único vector de retardos, y por lo tanto, no va a resultar posible determinar la posición de la fuente, pero si la dirección y sentido.
"""

# ╔═╡ f55143df-f8ea-43c4-a581-565221c8db4d
md"""
Se seguirá realizando un análisis cualitativo de los retardos, observando una sección de las 5 señales acotada en tiempo y se extraeran conclusiones.
"""

# ╔═╡ 39ad8c09-8a38-4985-9d6d-c68a3ee7fc83
let 
	
	tiempo=range(0,length=length(micro_1),step=1/fs)
	plot(plot(tiempo, micro_1;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señal 1 de los distintos microfonos",
			xlims=(1,1.01)
			))
	plot!(tiempo, micro_2;
			label="Microfono 2",
			)

end 

# ╔═╡ 17daccc4-5ed1-4b55-82dd-cd7588865f00
let
tiempo=range(0,length=length(micro_1),step=1/fs)
plot(plot(tiempo, micro_1;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señal 2 de los distintos microfonos",
			xlims=(12,12.01)
			))
plot!(tiempo, micro_2;
			label="Microfono 2",
			)
end 

# ╔═╡ 91c82ac4-bb55-4b5a-8b4d-c2e2d1d3c12a
let
tiempo=range(0,length=length(micro_1),step=1/fs)
plot(plot(tiempo, micro_1;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señal 3 de los distintos microfonos",
			xlims=(22,22.01)
			))
plot!(tiempo, micro_2;
			label="Microfono 2",
			)
end 

# ╔═╡ 91e7748c-ad9f-4537-ba28-3ea9ff428609
let
tiempo=range(0,length=length(micro_1),step=1/fs)
plot(plot(tiempo, micro_1;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señal 4 de los distintos microfonos",
			xlims=(36,36.01)
			))
plot!(tiempo, micro_2;
			label="Microfono 2",
			)
end 

# ╔═╡ 65515e36-f9e2-4d29-a995-c08206aed386
let
tiempo=range(0,length=length(micro_1),step=1/fs)
plot(plot(tiempo, micro_1;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señal 5 de los distintos microfonos",
			xlims=(47,47.01)
			))
plot!(tiempo, micro_2;
			label="Microfono 2",
			)
end 

# ╔═╡ f56bba0b-124c-469f-98c7-521e96011e0a
md"""
Se observa que en la primera y última señal el segundo micrófono está atrasado respecto al primero, y en el resto de las señales sucede el caso contrario, por lo cual, se entiende que para la primer y ultima señal el sonido efectivamente proviene de atrás a la izquierda, y en el resto del lado contrario tomando los sentidos de referencia que se muestran a continuación:
"""

# ╔═╡ 45a4ccb0-2331-44d9-ad99-66c4662d1866
md"""
$(LocalResource(joinpath("resources", "img", "referencia.png")))
"""

# ╔═╡ d380ae6f-61eb-4cd6-9cf8-06d2ebd4ab08
md"""
Por último, se aplicará a las señales el algoritmo para calcular el retardo calculando el GCC-PATH por ventanas de tiempo, se tomara un valor representativo que nuevamente será la mediana y, finalmente, se calculara la dirección de la fuente sonora. 
"""

# ╔═╡ 672b033e-2b4f-454e-95dc-42f654099c89
begin
	#sobremuestreo 
	
	micro_1sm=filtrado(upsample(micro_1,L))
	micro_2sm=filtrado(upsample(micro_2,L))
	
	evtempej11=ev_temp(N1*L,delta_n1*L,micro_1sm,micro_2sm,fs*L)
end ; 

# ╔═╡ 77001f1c-d704-433f-af16-f58c0c241303
let
	tiempo=range(0,length=length(evtempej11),stop=length(x1)/(fs))
	plot(tiempo,evtempej11;
	title="Evolución temporal de los retardos",
	ylabel="retardos [s]",
	xlabel="tiempo [s]"
	,label="retardo")
end

# ╔═╡ 51dc96d8-afcd-444c-8665-d1735cf5500d
begin
	retx1=median(evtempej11[1:round(Int64,length(evtempej11)/5)])
	retx2=median(evtempej11[round(Int64,length(evtempej11)/5)+1:round(Int64,length(evtempej11)*2/5)])
	retx3=median(evtempej11[round(Int64,length(evtempej11)*2/5)+1:round(Int64,length(evtempej11)*3/5)])
	retx4=median(evtempej11[round(Int64,length(evtempej11)*3/5)+1:round(Int64,length(evtempej11)*4/5)])
	retx5=median(evtempej11[round(Int64,length(evtempej11)*4/5)+1:end])
end;

# ╔═╡ 57ce06c6-7865-466c-a484-eecacf570980
md"""
Efectivamente el valor de los retardos son consistentes con lo mencionado previamente y, finalmente, se está en condiciones de graficar la dirección de la fuente de sonido.

Se considero, por falta de información que los micrófonos se ubican en (2,00 m; 1,00
m) y (2,05 m; 1,00 m).
También se tuvo que tomar la consideración de que el arcocoseno se define, en su forma biyectiva en el soporte (-1,00; 1,00), es decir, en este caso, no se verifica
para ningún valor. Luego, se realiza un corrimiento en 2 unidades (en caso de señal 1, se suma 2) para poder trabajar con los valores de retardo dados. 


"""

# ╔═╡ 5958430f-bae1-49c5-834e-6cb8c01ee9ce
function recta1(retardo, posx, posy, x) 
	m=-tan(acos((c*retardo)/(posx-2)-2))
	b= 1- m * posx 
	y=m .* x .+b 
end

# ╔═╡ 50a9dd69-a52d-4c9c-a1b3-cd23559c2b89
function recta2(retardo, posx, posy, x) 
	m=-tan(acos((c*retardo)/(posx-2)+2))
	b= 1- m * posx 
	
	y=m .* x .+b 
end

# ╔═╡ 906280a7-fa62-48f9-89e4-08deb4c98a7b
md"""

Por último, se llega al grafico que se muestra a continuación
"""

# ╔═╡ 584ac72f-7c19-41c2-9b0d-d5dd79dd3e2c
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1)]
	#x3=range(2+3*d; length=4, step=1)
	rectax1= recta1(retx1,2+d,1,x)
	rectax2= recta2(retx2,2+d,1,x)
	rectax3= recta2(retx3,2+d,1,x)
	rectax4= recta2(retx4,2+d,1,x)
	rectax5= recta1(retx5,2+d,1,x)
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,rectax1; 
		xlims=(0,3) 
		,ylims=(0,4),
		label="señal 1",
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,rectax2,label="señal 2",)
	plot!(x,rectax3,label="señal 3",)
	plot!(x,rectax4,label="señal 4",)
	plot!(x,rectax5,label="señal 5",)
	
end

# ╔═╡ 3bb77869-35ab-4bd5-bc85-95a8f9fa2ad7
md"""
El resultado observado coincide con el explicado de forma cuantitativa, para el caso de las señales 1 y 5, las señales provienen de debajo a la izquierda de la posición de los micrófonos, y en caso de señales 2, 3 y 4, de debajo a la derecha. 

Esto nos indica que el algoritmo planteado durante el proyecto funciona de forma correcta en un caso de aplicación, y permite obtener la dirección de una fuente de sonido.

"""

# ╔═╡ 406b570c-2f5d-4973-9912-8160b3b809d4
md"""
## Ejercicio 12 (opcional)

!!! info "Aplicar al caso del oído humano: fuente en movimiento"
	Escuche la señal `audio3.wav` donde se simula una fuente sonora en movimiento. ¿Que percibe que está sucediendo? Utilice el algoritmo de estimación de retardos para analizar la evolución temporal de los mismos.
"""

# ╔═╡ 6bc065a7-05f8-4f5a-be44-e67e6693636f
md"""
#### Caso de aplicación II
"""

# ╔═╡ 39fab87d-19c3-4686-ac26-eb5c5befd413
md"""
En la última sección de este proyecto se analizará el "audio3.wav", el cual consiste en una fuente con movimiento de tipo circular como se puede escuchar a continuación.
"""

# ╔═╡ 29d587a9-d990-4440-93b1-7ff1356a105b
begin
	x_e12, sr_e12, = wavread(joinpath("resources", "data", "audio3.wav"))
	sound(x_e12, sr_e12)
end

# ╔═╡ 97fddda7-6296-42b3-8f0d-9f7eaf9d396a
md"""
En particular, la señal reproducida se escucha en su evolución espacial moverse del centro a la izquierda hacia el centro a la derecha considerando los sentidos de referencia definidos en el punto anterior. 
"""

# ╔═╡ 58e4af03-8731-4f4b-9eb1-5210f2a87080
md"""
Se procederá graficando y analizando brevemente las señales obtenidas del audio3.wav y luego, se le aplicara los algoritmos implementados en las secciones anteriores para obtener con mejor precisión una idea de la ubicación de la fuente a lo largo del tiempo
"""

# ╔═╡ cd5ca5de-334e-43a3-bd7b-b10ba8dadbac
begin
	#Se definen la señal para cada mic
	micro_1ej12=x_e12[1:convert(Int64,length(x_e12)/2)]
	micro_2ej12=x_e12[convert(Int64,length(x_e12)/2)+1:end]
	
	micro_1ej12sm=filtrado(upsample(micro_1ej12,L))
	micro_2ej12sm=filtrado(upsample(micro_2ej12,L))
end;

# ╔═╡ 397c44b6-e55e-4811-9fb7-019570808818
let 
	
	tiempo=range(0,length=length(micro_1ej12),step=1/fs)
	plot(tiempo, micro_1ej12;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señales de los distintos microfonos"
			)
	plot!(tiempo, micro_2ej12;
			label="Microfono 2",
			)

end 

# ╔═╡ a2765c6c-b9ec-4e05-907b-2458c053551f
let 
	
	tiempo=range(0,length=length(micro_1ej12),step=1/fs)
	plot(tiempo, micro_1ej12;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señales de los distintos microfonos",
		xlims=(1,1.01)
			)
	plot!(tiempo, micro_2ej12;
			label="Microfono 2",
			)

end 

# ╔═╡ 797c1a49-95e0-4957-8f52-80e4c9eefd39
let 
	
	tiempo=range(0,length=length(micro_1ej12),step=1/fs)
	plot(tiempo, micro_1ej12;
			xlabel="Tiempo [s]",
			ylabel="Señal Mici",
			label="Microfono 1",
			legendtitle = "Señales",
			title="Señales de los distintos microfonos",
		xlims=(6.586,6.589),
			)
	plot!(tiempo, micro_2ej12;
			label="Microfono 2",
			)

end 

# ╔═╡ 1aca9c9a-8d54-4e5f-bc16-a27500ebfc4e
md"""
Nuevamente se pueden identificar dos señales temporales correspondientes a dos micrófonos distintos, por lo tanto, no va a ser posible tener una idea exacta de la ubicación de la fuente pero si de su dirección y sentido. Ademas, en este caso, se ve que existe un desfasaje variable en el tiempo, que se sabe que implica un cambio de percepción en la ubicación de la fuente sonora, es decir, que la fuente se encuentra en movimiento.
"""

# ╔═╡ 1ba0d5c6-6ba8-4e69-a17d-71b28e1b6d02
md"""
Se procederá de una forma análoga al ejercicio anterior, calculando la evolución temporal del retardo a través del algoritmo por ventaneo temporal de GCC-PATH con la misma ventana que se utilizó durante todo el proyecto y se analizaran los resultados.
"""

# ╔═╡ c83cd53f-f960-4320-a85b-28cc68709e16
begin 
	evtempej12=ev_temp(N1*L,delta_n1*L,micro_1ej12sm,micro_2ej12sm,fs*L)
end; 

# ╔═╡ 4f68ef80-77dc-4829-84b7-03122396e1ec
let
	tiempo=range(0,length=length(evtempej12),stop=length(x1)/(fs))
	plot(tiempo,evtempej12;
	title="Evolución temporal de los retardos",
	ylabel="retardos [s]",
	xlabel="tiempo [s]"
	,label="retardo")
end

# ╔═╡ 8649ab85-9b30-4f63-9ad3-3fb7375add47
md"""
Se observa que el grafico de los retardos en función del tiempo tiene una forma aproximadamente lineal, por lo cual, se espera ver un movimiento de la fuente aproximadamente circular o eliptico.
"""

# ╔═╡ 9e3b5072-215e-4545-bdde-bb24cc7885ab
md"""
Finalmente, se realiza un gráfico de una posible trayectoria de la fuente. Esto se hace a través del algoritmo de estimación de la posición de la fuente ya conocido. 
"""

# ╔═╡ cf363c91-9f18-41d5-8706-d04f6fe198b6
md"""
evoluciontemporal = $(@bind evoluciontemporal Slider(1:length(evtempej12)-1; show_value=true))
"""


# ╔═╡ bca62127-b02f-4f32-923e-d5827924b0bc
begin
	retini=evtempej12[1]
	rettemp=evtempej12[evoluciontemporal]
	retfin=evtempej12[end-1]
end;

# ╔═╡ cfeaad7f-0900-406d-8c32-9c6589f1178b
let 
	x=range(0; length=4, step=1)
	mic=[(2,1),(2.05,1)]
	rectaini= recta1(retini,2+d,1,x)
	rectafin= recta2(retfin,2+d,1,x)
	
	if 	rettemp>0.0001478
		rectatemp=recta1(rettemp,2+d,1,x)
	elseif rettemp<-0.0001478
		rectatemp=recta2(rettemp,2+d,1,x)
	else 
		rectatemp=recta(rettemp,2+d,1,x)
	end
	
	Plots.scatter(mic,markershape = :diamond, label="Mics")
	plot!(x,rectaini; 
		xlims=(0,3) 
		,ylims=(0,4),
		label="posición inicial",
		title="Estimación de la fuente con evolución temporal",
		xlabel= "X [m]",
		ylabel="Y [m]")
	plot!(x,rectafin,label="posición final",)
	plot!(x,rectatemp,label="posición temporal",)
end

# ╔═╡ 10aaebe8-5da9-47a8-8cb0-7ea85230a6cb
md"""
Trazando las distintas rectas para la evolución del retardo, modificando el valor de la variable "Evoluciontemporal" se puede notar la trayectoria de la fuente en movimiento, como ya se ha mencionado, no se puede obtener la posición exacta al tener solo dos micrófonos pero se puede observar su trayectoria circular.
"""

# ╔═╡ 1405cf78-34e5-45dd-9d45-e9173fa9f7b0
md"""
Nuevamente se puede observar que los algoritmos y los métodos desarrollados durante el proyecto pueden ser aplicados sin inconvenientes al cálculo de la posición de una fuente en movimiento y obteniendo resultados correctos.
"""

# ╔═╡ 7c1f487c-55d8-435f-b158-f14506410c1b
md"""
## Conclusiones 
"""

# ╔═╡ d0ddb947-ffc6-40df-9a35-4307db802c9a
md"""
Una vez culminado el proyecto, se puede concluir que su realización posibilitó el traslado de los conceptos teóricos adquiridos durante la materia a una aplicación concreta como fue la detección de la posición de una fuente de sonido. Además, teniendo en cuenta los impedimentos de la coyuntura actual, el uso de herramientas de programación como 'Julia' permitido llevar adelante el proyecto sin inconvenientes y, a su vez, ganar experiencia en el uso de las mismas. 

En relación con el desarrollo del trabajo se puede decir que se alcanzaron los objetivos y se pueden extraer diversas conclusiones acerca de los métodos utilizados. 

- En primer lugar, se observó que es posible simular la espacialidad de una señal de audio a través de la multiplicación de las pistas, y el correcto desfasaje entre ellas. Tambien, como se vio en el último ejercicio, se puede lograr a través de una aplicación dinámica de esta técnica conseguir la ilusión de movimiento de la fuente sonora. 

- Se utilizaron diversos algoritmos para la determinación de retardos entre señales. En particular se abordaron xcorr, gcc − phat y el algoritmo de estimación por ventaneo. Los resultados conseguidos fueron satisfactorios en todas las pruebas realizadas. Sin embargo, cabe la aclaración de la naturaleza de cada método, pues, para los dos primeros se mide el retardo como la máxima verosimilitud en todo el largo de las señales. En cambio, para el último, se realiza por ventanas de tiempo, lo que permite lograr tener una evolución de los retardos con el tiempo y, por lo tanto, que el algoritmo funcione para casos donde la fuente no es fija. 

- Se observa que el proceso de sobremuestreo fue fundamental a la hora de realizar el proyecto, permitió obtener señales con mayor cantidad de muestras y, por lo tanto, resultados más precisos. También es importante notar que este punto trae consigo una relación de compromiso entre la precisión debida al sobremuestreo y el tiempo de cómputo. 

- Respecto a los procesamientos de señales para reducir el ruido blanco, fueron utilizadas las técnicas del beamforming y el filtrado pasabanda. Se ha observado que filtrar la señal permite reducir de gran manera el ruido en aquellas frecuencias donde no se tiene señal util, mientras que el proceso de beamforming permite atenuar el ruido también en aquellas frecuencias donde se tiene información relevante de la señal.



"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
SampledSignals = "bd7594eb-a658-542f-9e75-4c4d8908c167"
SyS = "c6a8405e-5b14-471b-805c-851c27e4db3e"

[compat]
SampledSignals = "~2.1.2"
SyS = "~0.1.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ATK_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a5a8f114e4d70bee6cf82ed28b488d57f1fa9467"
uuid = "7b86fcea-f67b-53e1-809c-8f1719c154e8"
version = "2.36.0+0"

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "045ff5e1bc8c6fb1ecb28694abba0a0d55b5f4f5"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.17"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Blosc]]
deps = ["Blosc_jll"]
git-tree-sha1 = "84cf7d0f8fd46ca6f1b3e0305b4b4a37afe50fd6"
uuid = "a74b3585-a348-5f62-a45c-50e91977d574"
version = "0.7.0"

[[Blosc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Lz4_jll", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "e747dac84f39c62aff6956651ec359686490134e"
uuid = "0b7ba130-8d10-5ba8-a3d6-c5182647fed9"
version = "1.21.0+0"

[[BufferedStreams]]
deps = ["Compat", "Test"]
git-tree-sha1 = "5d55b9486590fdda5905c275bb21ce1f0754020f"
uuid = "e1450e63-4bb3-523b-b2a4-4ffa8c0fd77d"
version = "1.0.0"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dcc25ff085cf548bc8befad5ce048391a7c07d40"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.11"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random", "StaticArrays"]
git-tree-sha1 = "ed268efe58512df8c7e224d2e170afd76dd6a417"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.13.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "32a2b8af383f11cbb65803883837a149d10dfe8a"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.10.12"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Configurations]]
deps = ["Crayons", "ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "b8486a417456d2fbbe2af13e24cef459c9f42429"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.15.4"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[CustomUnitRanges]]
git-tree-sha1 = "537c988076d001469093945f3bd0b300b8d3a7f3"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.1"

[[DSP]]
deps = ["FFTW", "IterTools", "LinearAlgebra", "Polynomials", "Random", "Reexport", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "2a63cb5fc0e8c1f0f139475ef94228c7441dc7d0"
uuid = "717857b8-e6f2-59f4-9121-6e50c889abd2"
version = "0.6.10"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "97f1325c10bd02b1cc1882e9c2bf6407ba630ace"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.12.16+3"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[ExproniconLite]]
git-tree-sha1 = "c97ce5069033ac15093dc44222e3ecb0d3af8966"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.6.9"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "70a0cfd9b1c86b0209e38fbfe6d8231fd606eeaf"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.1"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "9cde086faa37f32794be3d2df393ff064d43cd66"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.4.1"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b83e3125048a9c3158cbb7ca423790c7b1b57bea"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.57.5"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e14907859a1d3aee73a019e7b3c98e9e7b8b5b3e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.57.3+0"

[[GTK3_jll]]
deps = ["ATK_jll", "Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Libepoxy_jll", "Pango_jll", "Pkg", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXcomposite_jll", "Xorg_libXcursor_jll", "Xorg_libXdamage_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "Xorg_libXrender_jll", "at_spi2_atk_jll", "gdk_pixbuf_jll", "iso_codes_jll", "xkbcommon_jll"]
git-tree-sha1 = "1f92baaf9e9cdfaa59e0f9384b7fbdad6b735662"
uuid = "77ec8976-b24b-556a-a1bf-49a033a670a6"
version = "3.24.29+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "15ff9a14b9e1218958d3530cc288cf31465d9ae2"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.13"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "47ce50b742921377301e15005c96e979574e130b"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.1+0"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[Gtk]]
deps = ["Cairo", "Cairo_jll", "Dates", "GTK3_jll", "Glib_jll", "Graphics", "Libdl", "Pkg", "Reexport", "Serialization", "Test", "Xorg_xkeyboard_config_jll", "adwaita_icon_theme_jll", "gdk_pixbuf_jll", "hicolor_icon_theme_jll"]
git-tree-sha1 = "50ab2805b59d448d4780f7b564c6054f657350c3"
uuid = "4c0ca9eb-093a-5379-98c5-f87ac0bbbf44"
version = "1.1.8"

[[HDF5]]
deps = ["Blosc", "Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires"]
git-tree-sha1 = "1d18a48a037b14052ca462ea9d05dee3ac607d23"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.15.5"

[[HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fd83fa0bde42e01952757f01149dd968c06c4dba"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.0+1"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "c6a1fff2fd4b1da29d3dccaffb1e1001244d844e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.12"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InspectDR]]
deps = ["Cairo", "Colors", "Graphics", "Gtk", "NumericIO", "Pkg", "Printf"]
git-tree-sha1 = "17c53328ba0bab3fd19bf9c42387e484acf6740e"
uuid = "d0351b0e-4b05-5898-87b3-e2a8edfddd1d"
version = "0.4.3"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[Intervals]]
deps = ["Dates", "Printf", "RecipesBase", "Serialization", "TimeZones"]
git-tree-sha1 = "323a38ed1952d30586d0fe03412cde9399d3618b"
uuid = "d8418881-c3e1-53bb-8760-2df7ec849ed5"
version = "1.5.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "4813826871754cf52607e76ad37acb36ccf52719"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.11"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "12ee7e23fa4d18361e7c2cde8f8337d4c3101bc7"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.10.0+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libepoxy_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "aeac8ae441bc55be433ab53b729ffac274997320"
uuid = "42c93a91-0102-5b3f-8f9d-e41de60ac950"
version = "1.5.4+1"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[MAT]]
deps = ["BufferedStreams", "CodecZlib", "HDF5", "SparseArrays"]
git-tree-sha1 = "5c62992f3d46b8dce69bdd234279bb5a369db7d5"
uuid = "23992714-dd62-5051-b70f-ba57cb901cac"
version = "0.10.1"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "6a8a2a625ab0dea913aba95c11370589e0239ff0"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.6"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Mocking]]
deps = ["ExprTools"]
git-tree-sha1 = "916b850daad0d46b8c71f65f719c49957e9513ed"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.1"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[NumericIO]]
deps = ["Printf"]
git-tree-sha1 = "5e2bd9bee8b55b754ca61386df207abbfc266ef6"
uuid = "6c575b1c-77cb-5640-a5dc-a54116c90507"
version = "0.3.2"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2bf78c5fd7fa56d2bbf1efbadd45c1b8789e6f57"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.2"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9a336dee51d20d1ed890c4a8dca636e86e2b76ca"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.42.4+10"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "f32cd6fcd2909c2d1cdd47ce55e1394b04a66fe2"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.18.2"

[[Pluto]]
deps = ["Base64", "Configurations", "Dates", "Distributed", "FileWatching", "FuzzyCompletions", "HTTP", "InteractiveUtils", "Logging", "Markdown", "MsgPack", "Pkg", "REPL", "Sockets", "TableIOInterface", "Tables", "UUIDs"]
git-tree-sha1 = "6af6088f72ae82c8b6712047b5fe79c22016b878"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.15.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PolynomialRoots]]
git-tree-sha1 = "5f807b5345093487f733e520a1b7395ee9324825"
uuid = "3a141323-8675-5d76-9d11-e1df1406c778"
version = "1.0.0"

[[Polynomials]]
deps = ["Intervals", "LinearAlgebra", "OffsetArrays", "RecipesBase"]
git-tree-sha1 = "0b15f3597b01eb76764dd03c3c23d6679a3c32c8"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "2a7a2469ed5d94a98dea0e85c46fa653d76be0cd"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.3.4"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SampledSignals]]
deps = ["Base64", "Compat", "DSP", "FFTW", "FixedPointNumbers", "IntervalSets", "LinearAlgebra", "Random", "TreeViews", "Unitful"]
git-tree-sha1 = "4b7e413f20fa56fa47b8433c96f96a1acfe372a6"
uuid = "bd7594eb-a658-542f-9e75-4c4d8908c167"
version = "2.1.2"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a50550fa3164a8c46747e62063b4d774ac1bcf49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.5.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "2740ea27b66a41f9d213561a04573da5d3823d4b"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.2.5"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "a43a7b58a6e7dc933b2fa2e0ca653ccf8bb8fd0e"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.6"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2f6792d523d7448bbe2fec99eca9218f06cc746d"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.8"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "000e168f5cc9aded17b6999a560b7c11dda69095"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.0"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[SyS]]
deps = ["DSP", "FFTViews", "FFTW", "FileIO", "GR", "InspectDR", "IterTools", "JLD2", "LinearAlgebra", "MAT", "Plots", "Pluto", "PlutoUI", "PolynomialRoots", "Random", "Reexport", "SampledSignals", "Statistics", "Unitful", "UnitfulRecipes", "WAV"]
git-tree-sha1 = "5ffefa8766ae2e4f6fdf061a5ea30a1c2ae52a1f"
uuid = "c6a8405e-5b14-471b-805c-851c27e4db3e"
version = "0.1.14"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableIOInterface]]
git-tree-sha1 = "9a0d3ab8afd14f33a35af7391491ff3104401a35"
uuid = "d1efa939-5518-4425-949f-ab857e148477"
version = "0.1.6"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "8ed4a3ea724dac32670b062be3ef1c1de6773ae8"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.4.4"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimeZones]]
deps = ["Dates", "Future", "LazyArtifacts", "Mocking", "Pkg", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "81753f400872e5074768c9a77d4c44e70d409ef0"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.5.6"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "7c53c35547de1c5b9d46a4797cf6d8253807108c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.5"

[[TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "b3682a0559219355f1e3c8024e9f97adce2d4623"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.8.0"

[[UnitfulRecipes]]
deps = ["RecipesBase", "Unitful"]
git-tree-sha1 = "d0bd83ffda53773c3ed181c23fe5a5655d0ff41e"
uuid = "42071c24-d89e-48dd-8a24-8a12d9b8861f"
version = "1.4.0"

[[WAV]]
deps = ["Base64", "FileIO", "Libdl", "Logging"]
git-tree-sha1 = "1d5dc6568ab6b2846efd10cc4d070bb6be73a6b8"
uuid = "8149f6b0-98f6-5db9-b78f-408fbbb8ef88"
version = "1.1.1"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcomposite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll"]
git-tree-sha1 = "7c688ca9c957837539bbe1c53629bb871025e423"
uuid = "3c9796d7-64a0-5134-86ad-79f8eb684845"
version = "0.4.5+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdamage_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll"]
git-tree-sha1 = "fe4ffb2024ba3eddc862c6e1d70e2b070cd1c2bf"
uuid = "0aeada51-83db-5f97-b67e-184615cfc6f6"
version = "1.1.5+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libXtst_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "Xorg_libXi_jll"]
git-tree-sha1 = "0c0a60851f44add2a64069ddf213e941c30ed93c"
uuid = "b6f176f1-7aea-5357-ad67-1d3e565ea1c6"
version = "1.2.3+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[adwaita_icon_theme_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "hicolor_icon_theme_jll"]
git-tree-sha1 = "37c9a36ccb876e02876c8a654f1b2e8c1b443a78"
uuid = "b437f822-2cd6-5e08-a15c-8bac984d38ee"
version = "3.33.92+5"

[[at_spi2_atk_jll]]
deps = ["ATK_jll", "Artifacts", "JLLWrappers", "Libdl", "Pkg", "XML2_jll", "Xorg_libX11_jll", "at_spi2_core_jll"]
git-tree-sha1 = "f16ae690aca4761f33d2cb338ee9899e541f5eae"
uuid = "de012916-1e3f-58c2-8f29-df3ef51d412d"
version = "2.34.1+4"

[[at_spi2_core_jll]]
deps = ["Artifacts", "Dbus_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXtst_jll"]
git-tree-sha1 = "d2d540cd145f2b2933614649c029d222fe125188"
uuid = "0fc3237b-ac94-5853-b45c-d43d59a06200"
version = "2.34.0+4"

[[gdk_pixbuf_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Xorg_libX11_jll", "libpng_jll"]
git-tree-sha1 = "031f60d4362fba8f8778b31047491823f5a73000"
uuid = "da03df04-f53b-5353-a52f-6a8b0620ced0"
version = "2.38.2+9"

[[hicolor_icon_theme_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b458a6f6fc2b1a8ca74ed63852e4eaf43fb9f5ea"
uuid = "059c91fe-1bad-52ad-bddd-f7b78713c282"
version = "0.17.0+3"

[[iso_codes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5ee24c3ae30e006117ec2da5ea50f2ce457c019a"
uuid = "bf975903-5238-5d20-8243-bc370bc1e7e5"
version = "4.3.0+4"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─ce0cbc70-cab3-11eb-0306-67a77845ad26
# ╟─3d288dd5-f787-499d-a2d6-d1397f9648c6
# ╟─c05a56df-73e6-4173-bd30-07891e168186
# ╟─d8812310-d724-411a-9a4a-e93e851dcb42
# ╟─36abb369-5bf7-4c46-bc74-9e963c4d4fd1
# ╟─8573c36c-fd93-4618-9ca9-abcc3cbe21c6
# ╟─f9e7c093-b8f2-4f60-b1ad-268a3f3616b2
# ╟─7f10b5e1-0007-4ef4-99a1-8a0d1a7e9df2
# ╟─50e02d9a-ad8b-4918-9491-6ba6ba4b7105
# ╟─48fc1ac8-bd19-420b-9ffa-f94d6c0ba51f
# ╟─884c7637-eb5a-450e-b93a-dc8ba7814fd4
# ╟─e0f67768-4704-430e-88eb-b8d6a519c233
# ╟─46294fbb-c010-499f-bc8e-96c43f25a2d1
# ╟─0c2a3c23-cd83-46ef-888c-10146ac04108
# ╟─6a7e0ffd-c055-4057-b1cb-f123536de183
# ╟─64c61ca0-d827-4ce9-bb64-05541e6ffdad
# ╟─56c0df38-c450-4fd0-91f9-9af6f35c9211
# ╟─40d34e86-3797-4138-9ee2-5a0fc4f9b479
# ╟─17a55ed1-b1ca-4393-92b7-d630424e913b
# ╟─9d081b37-5f5e-44af-9803-d34c3b97f4c0
# ╟─4c15b9f8-fd1c-47ea-af2d-dfe28ab7e274
# ╟─c1e8523b-75d3-4020-9f4f-656fa3572ab5
# ╟─9611dd8b-e614-4fd8-9053-7a9b4d7fa6ce
# ╟─29ae754e-e793-4543-a023-61450f274c9d
# ╟─3a655117-994d-47f4-a1cb-8e603667d764
# ╟─7e479075-e0c4-487c-b37f-615354515b7b
# ╟─e7267aed-538b-4f9d-a193-8b386685856d
# ╟─756b8b31-2083-4b13-a964-6e8194956562
# ╟─25450c0d-5b7c-49cb-a71b-a75e8bd4b9f1
# ╟─18bc3d93-2d01-404d-87eb-272fa05f20b8
# ╟─22a600c7-7f06-4777-af2e-8a2a017b39c8
# ╟─7a588563-1a37-4601-9832-179aee054700
# ╟─0a5489d5-17af-40f9-9fd1-f2049762380e
# ╟─4511b425-1bee-4247-81f7-49a973f5dadb
# ╟─02dabd09-8e2c-442b-a4f5-f5be1223b0b1
# ╟─927e5b2c-6036-42a4-b68e-47ea716b5cd5
# ╟─91ae961d-d65c-4bfb-b424-b2fe492f0d80
# ╟─077118d3-a3f6-4519-8260-e842c79c53c4
# ╟─6f709d2d-a75e-43fd-a1c2-ab0cfa39c131
# ╟─04d6d252-da05-42e9-b34b-e3b6d4f7d391
# ╟─daa16c6d-c22c-4253-a85e-072f3610b961
# ╟─7ebeb41b-34a2-4a6a-97b2-6427c38556cb
# ╟─8ce55995-f2f7-4df2-84ea-db450e0057a0
# ╟─04f3b49b-f50b-44e9-b349-34bf85243113
# ╟─e81719d6-f382-4af4-ae69-d8f23fa8d7fc
# ╟─abdd912c-2211-4062-8963-3eecdd7fee8a
# ╟─337d0730-e4d8-4d2e-a020-2cd75781b6b7
# ╟─51684a58-6584-49bd-86ef-ba8e86d0d8f9
# ╟─04da4c13-c2b7-404c-bb76-12969e2592d7
# ╟─330b9b0a-4d95-4d0b-86e3-b8fdf96099c2
# ╟─620d4bd2-08d5-43b6-b115-0bd005ccc0aa
# ╟─fed25724-ba1f-4ea3-be41-7d9f93409d51
# ╟─04bdd425-69cb-45e9-a114-99dcf7cdefed
# ╟─8e3a72a2-15a4-47fd-be48-9d64cf2b693d
# ╟─efae1d01-bd7b-4865-988d-4ecdc750b93e
# ╟─956d3df4-c08c-40e4-91e3-8aa59bb8476c
# ╟─580d94c3-9fae-48fa-b89e-3200dc869318
# ╟─b0d853ec-778b-4d12-b2c7-87a32a38be01
# ╟─fe847b3e-720e-4ee8-a7b2-6230e9e023df
# ╟─fda59bad-8109-4a74-beb8-feea929b05d1
# ╟─5ad1cb51-d8ca-4f69-859b-f1f10e56f2a1
# ╟─333940e7-3ff1-4361-b895-c888f8e01b41
# ╟─fce74867-93bf-4017-8d75-b046a47196de
# ╟─11d7de61-11e0-4c9c-9814-e243c0ba4f89
# ╟─c26290a4-853e-415d-9edb-1c7f59ed50d6
# ╟─3209558d-c77a-406c-a90e-7a41d115f025
# ╟─09e8c69b-0af7-42bf-a66e-6eaff856300f
# ╟─9a13e5cb-300c-4519-8d5e-703e948fbb7b
# ╟─cf74bf4c-999d-47db-9480-70feaa7e5699
# ╟─4fffb4ed-7142-4205-9eeb-d6bf85cce9b8
# ╟─4460e520-2ddc-41a6-838d-380094d25f9a
# ╟─24345e17-2d95-4846-970f-9ff8056396e5
# ╟─25dfbbd9-9bd0-4047-b503-4e8ba28c6976
# ╟─98e32733-fddc-4503-93e3-0a5316bb0043
# ╟─480b8cf9-7f7f-4345-a451-6f4ae8628217
# ╟─ff458a1f-5ab7-4801-96c3-e7c482e3de86
# ╟─108745cd-060a-4cb9-8fca-f2b9df0908fe
# ╟─3080c05b-7bd5-41b9-9f3d-a03dfffcfe00
# ╟─ba69d533-7991-459e-b6c0-d84fade6f473
# ╟─b246f5a9-edef-42f0-8e2b-56f1ca29b5ef
# ╟─4eb8c90b-dece-4e72-839b-b241a933e502
# ╟─bd28a4a6-16fe-4b20-92ab-d029d0b07d5b
# ╟─9e8f736d-7339-4789-8780-1a4e162834cf
# ╟─151dd287-1f69-44c8-8b84-216c3154cdb3
# ╟─fa3bf2bf-42b9-47d6-ae51-9bfcf7bd9bdf
# ╟─8ea866ea-4374-428b-ae0f-dabef74d1ccb
# ╟─e30ec405-1ce3-44f5-887b-36ac0207ee18
# ╟─489f1aaf-40f8-4822-b382-a8e59233dad6
# ╟─375d2e36-d9c8-4b22-8cff-d4845a005489
# ╟─7d0ccb56-6061-443e-abbb-92e719f7cb64
# ╟─d0a8248f-633d-46ac-b2bc-95811b67c7ec
# ╟─3d57fe99-91ae-4312-9a45-4990b79d75b7
# ╟─d00002d4-1e9a-42da-9733-d1970a368de7
# ╟─0284914d-16ea-45b8-9d91-73fdc12fa4d9
# ╟─e5ca455c-1e4f-4f69-a4a3-dfe687b4551e
# ╟─20b349d2-fbaf-4fbe-89b4-292fcdf87e0a
# ╟─f750393e-070d-4e11-880f-4280025639a0
# ╟─4f94c873-1b3a-44f5-8b85-496bdd9321ba
# ╟─3071adcd-958f-4919-8ff5-60116b38aefb
# ╟─0a67d45c-4297-4adc-a998-5fcc22d11436
# ╟─14372d6c-030f-450c-9ac8-865ccdaa5ab5
# ╟─876bc7c7-d937-499f-8b90-c4b2cdaf39ea
# ╟─2d7df849-334e-4469-91d6-6a2b8ad98ed9
# ╟─78dd184d-66bd-4467-81d9-dab4cb870fb4
# ╟─8c943d93-4a37-43a7-874b-9891b7aa2004
# ╟─7e9c2d80-fb2a-4afa-901d-e2081c9dfe59
# ╟─e6f911a7-18d3-4e38-8655-5d87b7965a59
# ╟─94ff3028-92d1-421f-9b05-d1cf300a7b2e
# ╟─6a5bf067-9397-47a1-9532-12b565d53250
# ╟─5511ec91-c9b2-4068-98e6-604c6229d23a
# ╟─0fff5207-1645-4787-926c-43c9336cfef0
# ╟─4eeeb935-a768-4249-818e-7173e2ae8dda
# ╟─4ee02a45-884c-4033-95e8-963c9094b7ab
# ╟─38164d3c-e368-4383-b9aa-9d4f1ebf441c
# ╟─340d90bc-dfe8-46cc-a4b6-b6b63c5b019a
# ╟─3f050d4b-9e17-4f55-9b52-d8373b5950f9
# ╟─02b8c945-0471-401c-9afe-6f6a8c9f000c
# ╟─7492e39a-9e41-47ce-9bc0-cf83a6e14de7
# ╟─766747af-23f1-498c-b047-68dd7b210e96
# ╟─71c4be28-5702-4ff3-80e2-505f3630825c
# ╟─874ef93e-d954-4949-9ae5-7941b5041060
# ╟─4a7cf4af-f5e7-43a9-8a40-f0a614a3c7b7
# ╟─e63c2382-44fb-4b7b-bb10-e733a02cf887
# ╟─504e8eb7-6521-422d-94ab-5aeae670e5e7
# ╟─d15a12c9-4681-4bee-ad72-4e7c7147232f
# ╟─b1eea814-27a8-41a6-91f5-5cd34cef4057
# ╟─932dc23b-a03e-49fc-ad23-87e52cb3354d
# ╟─c10b5c90-9ea4-4bd6-9dab-bd8dfdd11721
# ╟─4990514a-0aea-457c-ad2f-b7f45e18b216
# ╟─d082c5e0-7ecb-41cf-876d-f8f53f55ece1
# ╟─67961b6d-163d-477c-b434-6a1e02e86ad0
# ╟─6766a189-b48b-45af-9a6c-1801bc002778
# ╟─14b88f72-4c0f-49ae-a332-e59bb6e1b9ef
# ╟─47408390-2d25-4649-8ad9-651172be2236
# ╟─6f03ba67-24d3-4757-929a-70840de5ce12
# ╟─4ed9a0f3-8d7a-43bb-9feb-51b378a9213d
# ╟─2dbdbfeb-09aa-4b36-b08a-91c0ff9ec3d2
# ╟─f22ed4be-1fbd-49be-b85c-4a8a86675c71
# ╟─3458f44c-e0e0-42cb-8ca0-7fdf6cc34b01
# ╟─c41b8cf5-42bf-47bd-8cac-bc9784bd2c1e
# ╟─783d3941-c0de-401c-99d8-7b36817b51c9
# ╟─622f34ee-a95e-456e-9a97-548a6b27175a
# ╟─c86cb561-2d4a-4821-99df-fac99fe00375
# ╟─56b4bbb8-8f9e-4ee2-ac17-6fd141fe706d
# ╟─56750751-d4d2-429c-b485-e872accb7ce7
# ╟─b6c5f649-517c-4373-ad6d-3ce54bc9f6df
# ╟─9965a443-afed-42aa-854c-663e352cf806
# ╟─56c0ed95-4b2f-4c40-958d-8c067e4880a2
# ╟─c5d41bef-ec2f-4bc4-8faa-a16b99c328c4
# ╟─ad5b7d2c-25b7-4286-bf40-776eeb404247
# ╟─a9655e9a-0539-4c8a-b5b3-d585c2877f76
# ╟─849516fe-636b-4e06-827b-29a884f2fad3
# ╟─fea1823c-4715-47bc-a413-647291e0178c
# ╟─967ba308-b327-4a84-a723-408b02dbb5db
# ╟─0d8c68f9-3f3e-488f-bf1f-096800b9976f
# ╟─aec82054-fa4b-4a99-9d37-e48f4a8f8679
# ╟─f885d5a3-9a7d-4d6e-bd87-af2c87e42114
# ╟─d80800fa-c05a-4d22-97e3-d42b275db34e
# ╟─f1023662-9886-403c-ab56-5c07c270bfd0
# ╟─2e91672a-7fca-473c-b944-3c5b06582f30
# ╟─b46de96b-d58b-4f77-80b9-e9bb747bef23
# ╟─6fdcee1d-b4f6-4cff-9fd4-8ff3de88b8ce
# ╟─30ca3aff-7bc8-42b9-8258-d89f92348654
# ╟─4129bfc2-e515-4ebf-ab3a-ccdde72c0f20
# ╟─105d6a25-0421-4e87-b5e8-574496dff0e7
# ╟─fda32acf-480a-4f22-8ba5-c1e8a17a536f
# ╟─ecc02872-a022-4740-a15b-75685d0bf330
# ╟─3b865b2e-23c4-4a12-a5d7-2b0d49b9cece
# ╟─9f0028a8-fcb3-40e2-bd76-8c691c801462
# ╟─d4071362-ef3f-4890-a84d-5d0d3b0a1580
# ╟─d0fc4137-dd3f-458f-8c9e-90db111737d9
# ╟─9be14c8a-c62d-442f-a1c7-3888e12fc2c4
# ╟─5e3dffe8-2058-438b-a2c8-75e5b6bfeec8
# ╟─79783530-6d26-406e-944e-f2f74d3d3c7c
# ╟─dfec1f32-8ed0-4b90-9824-916f38e1257b
# ╟─bc1d24c6-04d0-4d72-84de-177b5a94916c
# ╟─2bff938e-24a0-4ad0-bf51-17f92a3a3967
# ╟─c0d1c0d9-7113-490d-8ede-e939a832f15f
# ╟─55d3d834-1ee7-415f-807d-a4d11f21a45f
# ╟─97f5ae86-3140-47aa-a414-123183ad6c1f
# ╟─4b2bec95-10bd-4999-8cec-dd006238ef90
# ╟─9590b989-397a-4134-8295-e85d617a04f3
# ╟─d48e6c17-316a-4645-8eda-8d16937fe088
# ╟─20195a24-a17d-41ed-851c-750a85987750
# ╟─533c9c63-43e9-4850-9d64-1a2cf430b4b8
# ╟─8889bc90-3936-4f8a-8708-6978239e4d74
# ╟─06cf8a4b-0042-4861-8ca3-11ae854e645c
# ╟─caf3cc1e-344e-415f-bbe5-899a40364ec4
# ╟─40113269-c56c-43fe-ae0a-4f1b9a07ede8
# ╟─a5b9da6b-b033-4176-9d03-b7d5658561fb
# ╟─37f43170-9576-4f36-b750-308415e36b66
# ╟─e25c4ecb-df77-4c33-88ec-466c400dbf19
# ╟─aefa8119-4408-4343-a351-e71292e900bb
# ╟─b9dca6e4-254b-4b94-91ba-6f016084229b
# ╟─774508d2-ed29-445c-b758-671d89b4a0ff
# ╟─ae9cb4d5-6681-4a44-9c29-a9cf989c3ae7
# ╟─0b382099-9142-4711-ba5e-c8c2606c02a6
# ╟─b6900f4d-5025-41b1-97f2-bd497d8269a2
# ╟─f7e185b1-0a43-4668-bd66-4c010e778979
# ╟─edf382d9-8ee2-4266-8ac5-9f41d4478885
# ╟─6b156a3e-3f52-40cf-b68c-d85160b2a982
# ╟─c36023ae-142b-42fa-851b-6aef176d2e47
# ╟─16c19fe5-010a-4b9b-8de8-46ec0ce211a9
# ╟─a0ae3f60-780b-421f-a241-9b0cbc885ab4
# ╟─7913d114-0669-44e1-a046-5d98a8ea75f3
# ╟─e9ed99e4-bec6-46da-80f3-e5714b20aef2
# ╟─3f362919-6099-4eb1-ba2a-849d9c87989d
# ╟─d9a7b0c2-f5b9-4529-9264-61bb813d537f
# ╟─508c1cd2-c237-415c-a7b5-e87f0187074d
# ╟─fea4f834-86af-4377-9c34-e03de242f76d
# ╟─119f5de8-b783-4486-bc7e-29b9c3d69181
# ╟─a7b3b398-7ecf-4602-b070-9f746dbb8c72
# ╠═0f693496-915f-41bd-9109-14d345a9a8c4
# ╠═d31af6b1-2ac0-437e-9fb1-35d10be8643b
# ╟─b9a99a9e-da30-42c9-b1a6-c037753d800a
# ╟─88b00919-59bd-44da-b7e4-5e44e5553ec3
# ╟─31e8ea41-7448-484c-a4a6-ff66bc613d74
# ╟─a12f62a3-cbee-4feb-8307-f966047f1734
# ╟─2b8b7868-4a6f-475f-b964-8457ffa42c6f
# ╟─ea533eae-a753-4921-b99d-68e1baf0f396
# ╟─5e68d2e3-03d2-4310-8085-8979bff3d459
# ╟─4e398fec-0b0f-410a-a7b7-d4ad3f4f097c
# ╟─d74b4ab0-e51a-4e69-92be-23b48b24d4cb
# ╟─b4e71eb6-0530-43b2-b746-10b487acec75
# ╟─120892eb-83fe-430a-8bd0-20cd2b66f88c
# ╟─6bddbbbe-560f-4993-a20b-08fc9f9b78c4
# ╟─8272acb0-402e-48d0-a94c-3814a4c9590e
# ╟─c4ce8591-38f6-4592-9321-c7df9ffe444f
# ╟─6baea40d-0b53-4c21-b4fb-df2bd91bc023
# ╟─41e96a0e-2988-4c8a-b5fa-dcf9da074cd7
# ╟─53cd8588-e646-47b1-ad1c-76524d636fe1
# ╟─40690521-dfc1-4aac-9560-ef8139a60de3
# ╟─66484379-c718-44b5-b5d5-6d5411bd3a08
# ╟─f82b901d-b7c7-4d7a-91bd-6d645fb957eb
# ╟─0fe505b9-687d-45ce-a27f-a66918a00891
# ╟─9e1d4450-e929-4516-ac89-8f8e5e886e3f
# ╟─ab8baba6-8617-4c9e-9fd2-aaf5e1224eb6
# ╟─c3e01594-911a-49f0-8271-29f0dc75d9c0
# ╟─4a1ac7d1-5ec1-491a-a0cb-454abd52d195
# ╟─a823b064-d2dc-4128-8aea-763d59f75639
# ╟─c700e207-aabd-49e9-a3e1-c70f2b7b5adb
# ╟─151e5b21-8e3c-434e-8b23-c33453553d83
# ╟─0df73c2c-2a9e-4692-9f1c-efe851bcea84
# ╟─2b158ebc-fa98-47d0-8e30-3a9244e55b49
# ╟─2eb38ae7-f36f-4a60-9282-713a34caad43
# ╟─14dc0be9-59a7-47b5-b4e8-d853e2b084ed
# ╟─3155855e-6a19-4b38-a580-5d31024bc609
# ╟─a8d0b5b6-bb9a-4550-92c1-89cb37e53307
# ╟─b4be2d3f-d696-4a93-a3ba-ad6e4ceb1e30
# ╟─17c31da7-1cea-41d8-a208-f041e88ba843
# ╟─9f40bd2d-dd4e-4612-815b-afe3cdd9c8bb
# ╟─db516f63-0390-4b62-837a-caebf65a5819
# ╟─02945b7e-a6a9-4c10-bfeb-332c4af4ea3f
# ╟─88884202-9a02-4103-ad39-19d647d41c15
# ╟─2f0cedfe-75d6-41fa-bf09-fda9d58e6442
# ╟─5fd47b3a-9157-48cd-affe-5652f6885e2b
# ╟─6df26d00-5044-4730-911a-122017cba985
# ╟─b6ab03fe-1122-4573-a751-2fc67d4ba765
# ╟─18ad4bac-02ba-4c1b-a1d1-d050370a73e5
# ╟─6b358c2d-8693-453c-842f-21dc8c17b0ab
# ╟─52ac97ae-c834-4120-a891-36bfca292f0f
# ╟─48249527-dc7c-4498-9829-b47db1e432de
# ╟─658bf76a-90b5-461b-962b-3029de315917
# ╟─9e5ccd51-dc5b-453b-9cf7-cc0f6c7f52e7
# ╟─a288098c-796e-4514-abf0-de68795f0b36
# ╟─aa2a8176-5a1b-4587-9a0b-499e81d7c5e6
# ╟─c19fcee9-aab5-44c0-a733-e0856e7717d9
# ╟─f89a11e1-421a-416f-9913-936dfd51baa3
# ╟─87d51648-dd34-4be5-984d-98ccba3f94a2
# ╟─14be827f-feff-4531-a7de-5ef7fae10ed7
# ╟─6ff9978e-8493-416c-84b2-4427542adf27
# ╟─0fe33cd1-93b0-4556-9a29-f110349f3263
# ╟─b75a210f-aaf5-46d8-ac73-cdc2827d8a02
# ╟─3c09ad96-4c26-49ec-a6a4-52e245c2c631
# ╟─1ad200a2-cada-4c67-8c50-b20015453a57
# ╟─00c2fa34-dd6c-4a53-95f2-54ea8520271c
# ╟─b51b3ec0-5c69-41dc-aed9-20646f93a05c
# ╟─9ef8c221-3200-4932-8b4a-79e94c806dec
# ╟─69104691-3c57-427e-8992-9f42c75b9a31
# ╟─dc2048ca-97a2-4463-8d55-5b6459b52e07
# ╟─ebe09117-2c47-413b-9903-76fcc3a5a14a
# ╟─43396f61-9d0c-4a4e-8e4e-dc8e86d9578b
# ╟─392ca647-47b2-43e7-b3aa-d549db7a2387
# ╟─e2c91eba-6db8-46aa-89f3-bc1872f82e10
# ╟─ad03d129-9304-4075-aff2-01d0ad0c6d62
# ╟─295bf743-b296-4288-8c1d-b24a6f58d2c0
# ╟─c23c82c7-e488-482c-85c2-2036c8a4a96c
# ╟─13181a57-9b0f-497a-98a6-30435c0885cc
# ╟─6aeb9021-2fd6-4a21-8d2f-a45012562752
# ╟─11d5b082-f469-42f1-9517-bcaf47734755
# ╟─1ee15258-932a-4f3e-8776-304f5259a850
# ╟─ffefb15d-e2bf-4dc3-97a5-15dfc3b2d40a
# ╟─4599fce5-a10e-4072-89de-b53de241d715
# ╟─f5904749-df66-4261-b36c-fd1eb7c274e1
# ╟─5a9f51f3-1f9c-41ab-bd94-62ea43c38dfb
# ╟─063ac4e4-2b5f-44a3-8ede-d6e6372934d9
# ╟─4bbc1821-6137-41a0-ad88-47427589faad
# ╟─b5a84c65-695e-490d-b611-020d34167b1d
# ╟─8f60a6b4-51b4-492d-8adc-8baa25e50b0f
# ╟─353383ca-c506-4680-ab58-e72a2fedc2b3
# ╟─49640e3e-ee91-4db8-95c1-e8cf68d11b97
# ╟─7bac0fd2-2169-4ff2-a6d8-26c06e467b06
# ╟─11142c3c-c6be-481e-8c47-e823b9222374
# ╟─e689b3e5-2b24-4927-9944-5b05e9342668
# ╟─f6708135-302a-495d-baec-64400245c50f
# ╟─0f30a07c-9cf1-4530-a64d-0ba725eda66a
# ╟─664b2755-b215-488f-9166-22b981913b68
# ╟─1e26e8e7-616c-4c65-bf9a-cae7c62b43ba
# ╟─43d350b4-78ae-45d0-9942-4061f3f91ef4
# ╟─a23b9352-5841-42c2-8917-35dff7478097
# ╟─cd369522-87fd-4e6b-ae38-d95a186db603
# ╟─79a61a00-f228-4217-873f-b4d76a83105d
# ╟─58605eb8-da2b-433d-ac6f-61c6d5dde804
# ╟─98275258-cb78-4302-9dfe-26d2bb2a982c
# ╟─cf567823-9b52-4a04-b606-bbab6e0f78c0
# ╟─44cafae7-2293-44ea-a865-4331b007a26e
# ╟─5d531437-f2a9-491e-96de-ceb1b77c12d3
# ╟─0a9cda03-2e2b-4792-9798-917eaab1cb65
# ╟─3dffbdef-3984-453d-a7da-24f0ce24a777
# ╟─99fdd233-d996-4635-9c4b-c9dd6b538881
# ╟─48a82e31-7cd1-4404-a94c-e7e0a8f18eba
# ╟─50114082-d794-42c8-bf78-0ab985a2c373
# ╟─58274f26-2679-4a17-ada7-74f697b8bb2f
# ╟─a2af829f-8979-4ca8-bd6b-2e840de3ac0f
# ╟─e1ee9a80-242b-40fb-b7d5-843ef970f78c
# ╟─3ebdc286-f99a-4cc2-b2b2-59ebb3aeb99f
# ╟─cd2a85d3-0d94-4d99-89a6-a1073c400e59
# ╟─5be8be44-73be-4b88-903c-ff74244469d6
# ╟─7362effd-e8d4-4df3-b163-a263860716ff
# ╟─917ae275-d71c-4561-b3f8-a308c5b46ac4
# ╟─fb4734d5-c2de-48db-9852-39d32454c8e7
# ╟─54b608ea-b06d-4fb2-bd23-202793a66cb0
# ╟─3ddc63ef-ce55-4fa3-8245-b0e1ff178334
# ╟─f39bc912-c883-45ee-a828-e8713c514392
# ╟─9870c04e-b23b-400c-9f22-ac77bd337cd5
# ╟─30390069-6418-4f5b-b05a-a5da54fd909b
# ╟─274e086e-567b-4669-9c5a-42bc8dbc01a5
# ╟─2d32c88f-9b87-44d2-9d6c-4d85d6fb4c0b
# ╟─750a0b81-161f-4c4e-8114-d00b5ead9baa
# ╟─25af3924-80b2-4138-9888-41c970b09a44
# ╟─d6babe7a-3185-41cd-884c-d48115380e3d
# ╟─fe407a65-e90e-4875-9317-6c5aa1742e5a
# ╟─ab24000d-8966-4a9f-b9e1-684e3d2e7df7
# ╟─ee3e998d-e370-4fa1-ad66-9ed3d2ced7a0
# ╟─e1de2b1a-505d-4d5e-9e6a-a3e396040105
# ╟─e39d3963-0916-414a-96df-ea426316509a
# ╟─c46ba773-77d1-410b-ae24-80c9334673e7
# ╟─e87b668e-1d3a-467d-88ff-84d667eed457
# ╟─90753c41-7c15-4b62-8d0a-aaf82261ccc0
# ╟─9983382c-4dc0-4e63-916f-2739b39d6313
# ╟─53696d50-45eb-4ac1-b536-4559c5ffd701
# ╟─9e25b504-772f-4b2b-a258-3c7980a0a19a
# ╟─869b61f0-c82a-497c-8f84-aa20b92cbf91
# ╟─c314dc24-0916-47b4-8a36-21e4d310bb36
# ╟─36f14035-c0d9-4bda-a864-b08e56ed9736
# ╟─f3bbb9e4-3c2f-4214-abdc-708f661d1da4
# ╟─2b54482c-cb5f-4343-a793-cf7d192ca1e0
# ╟─22db8952-d578-43ee-8a19-2221a40e5014
# ╟─4e40ffa4-f40d-4844-8d9e-d40126866f75
# ╟─1b1eaeb8-603b-4ddb-904c-538e65eb822a
# ╟─ee520187-009c-4c66-80b0-e15fdd1c74b2
# ╟─7cbbe305-5a60-4e36-b451-d066f52ed84f
# ╟─0f849f94-bf55-40f2-a1ca-4ce59a18c09d
# ╟─b23c2fc6-f135-4ce5-8373-44f4ba80a098
# ╟─de4da224-0e26-4f5b-99cc-a0f66d794066
# ╟─5b19ac2f-071f-498c-8590-4ae2b5d628d6
# ╟─b1192298-0943-40b1-b395-e75758740a65
# ╟─839ccd32-2666-42cb-9064-49c9fed9dfaa
# ╟─5430bc97-8dfb-4f21-a560-5b5e62bec6b9
# ╟─d91ae5ec-4db3-489f-b415-7f84bb409b68
# ╟─74849120-5209-4cb2-8ef5-53989f79b67f
# ╟─e4dc54c9-4514-4fb4-9c0c-11c2b1d8c74d
# ╟─289a66a9-e5e1-457d-b2a6-68edf250d36a
# ╟─97552660-5ae0-4b56-abf9-991a3e1d651b
# ╟─a8b84c71-b0da-4abf-b1df-f52afdbe76ee
# ╟─b6945a9c-7488-41de-9b52-508ea2d5bea5
# ╟─9e388585-e737-4335-bdf8-1a07e26bde48
# ╟─7191c39c-c80a-492c-a35e-d143b07a5a50
# ╟─5283ede3-28eb-4fc5-bfe1-31b71d4c937c
# ╟─f55143df-f8ea-43c4-a581-565221c8db4d
# ╟─39ad8c09-8a38-4985-9d6d-c68a3ee7fc83
# ╟─17daccc4-5ed1-4b55-82dd-cd7588865f00
# ╟─91c82ac4-bb55-4b5a-8b4d-c2e2d1d3c12a
# ╟─91e7748c-ad9f-4537-ba28-3ea9ff428609
# ╟─65515e36-f9e2-4d29-a995-c08206aed386
# ╟─f56bba0b-124c-469f-98c7-521e96011e0a
# ╟─45a4ccb0-2331-44d9-ad99-66c4662d1866
# ╟─d380ae6f-61eb-4cd6-9cf8-06d2ebd4ab08
# ╟─672b033e-2b4f-454e-95dc-42f654099c89
# ╟─77001f1c-d704-433f-af16-f58c0c241303
# ╟─51dc96d8-afcd-444c-8665-d1735cf5500d
# ╟─57ce06c6-7865-466c-a484-eecacf570980
# ╟─5958430f-bae1-49c5-834e-6cb8c01ee9ce
# ╟─50a9dd69-a52d-4c9c-a1b3-cd23559c2b89
# ╟─906280a7-fa62-48f9-89e4-08deb4c98a7b
# ╟─584ac72f-7c19-41c2-9b0d-d5dd79dd3e2c
# ╟─3bb77869-35ab-4bd5-bc85-95a8f9fa2ad7
# ╟─406b570c-2f5d-4973-9912-8160b3b809d4
# ╟─6bc065a7-05f8-4f5a-be44-e67e6693636f
# ╟─39fab87d-19c3-4686-ac26-eb5c5befd413
# ╟─29d587a9-d990-4440-93b1-7ff1356a105b
# ╟─97fddda7-6296-42b3-8f0d-9f7eaf9d396a
# ╟─58e4af03-8731-4f4b-9eb1-5210f2a87080
# ╟─cd5ca5de-334e-43a3-bd7b-b10ba8dadbac
# ╟─397c44b6-e55e-4811-9fb7-019570808818
# ╟─a2765c6c-b9ec-4e05-907b-2458c053551f
# ╟─797c1a49-95e0-4957-8f52-80e4c9eefd39
# ╟─1aca9c9a-8d54-4e5f-bc16-a27500ebfc4e
# ╟─1ba0d5c6-6ba8-4e69-a17d-71b28e1b6d02
# ╟─c83cd53f-f960-4320-a85b-28cc68709e16
# ╟─4f68ef80-77dc-4829-84b7-03122396e1ec
# ╟─8649ab85-9b30-4f63-9ad3-3fb7375add47
# ╟─9e3b5072-215e-4545-bdde-bb24cc7885ab
# ╟─cf363c91-9f18-41d5-8706-d04f6fe198b6
# ╟─bca62127-b02f-4f32-923e-d5827924b0bc
# ╟─cfeaad7f-0900-406d-8c32-9c6589f1178b
# ╟─10aaebe8-5da9-47a8-8cb0-7ea85230a6cb
# ╟─1405cf78-34e5-45dd-9d45-e9173fa9f7b0
# ╟─7c1f487c-55d8-435f-b158-f14506410c1b
# ╟─d0ddb947-ffc6-40df-9a35-4307db802c9a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
