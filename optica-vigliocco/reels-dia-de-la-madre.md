# Reels Día de la Madre: Óptica Vigliocco

**Fecha:** domingo 18/10/2026 · **Formato:** 9:16 (1080×1920), 11–13 s · **Material:** clips de la modelo con los lentes, sin IA.
**Mecánica:** promo con tarjeta (completar bancos, cuotas y vigencia en `build-reels.sh` → `PROMO_*`).

> Música: los reels salen **sin música** a propósito. Al subirlos, elegí un audio en tendencia desde Instagram (sección *Audio*), así no hay problemas de derechos y se gana alcance. Algunas sugerencias: un audio emotivo de piano o acústico para el Reel 1, y algo pop con ritmo marcado para el 2 y el 3.

---

## Reel 1: "Una mirada nueva" (emotivo, ~13 s)
**Objetivo:** instalar la fecha y generar guardados y compartidos. Sin precio.

| Tiempo | Toma (clip) | Texto en pantalla |
|---|---|---|
| 0–3,5 s | `modelo-1`: se pone los lentes, en cámara lenta (0,7×) | *Ella te enseñó a mirar el mundo* |
| 3,5–7 s | `modelo-2`: primer plano y sonrisa, en cámara lenta | *Ahora regalale* |
| 7–10 s | `modelo-5`: detalle o giro de cabeza, en cámara lenta | ***una mirada nueva*** (serif itálica) |
| 10–13 s | Placa rosa empolvado + logo | *Feliz Día, Mamá* · @opticavigliocco |

**Copy:**
> Ella te enseñó a mirar el mundo 💛 Este Día de la Madre, regalale una mirada nueva.
> Te esperamos en James Craik para elegir juntos el anteojo ideal 👓
> 📍 [dirección] · 💬 WhatsApp [número]
>
> #DiaDeLaMadre #OpticaVigliocco #JamesCraik #RegaloParaMama #Anteojos #Optica

---

## Reel 2: "Promo con tarjeta" (venta, ~12 s)
**Objetivo:** conversión. El gancho con la promo tiene que estar en el **primer segundo**.

| Tiempo | Toma | Texto |
|---|---|---|
| 0–2 s | `modelo-2`: mirada a cámara | Arriba: **DÍA DE LA MADRE** · abajo: **[X] CUOTAS SIN INTERÉS** |
| 2–3,6 s | `modelo-3`: anteojos de sol | **Sol** |
| 3,6–5,2 s | `modelo-4`: anteojos de receta | **Receta** |
| 5,2–6,8 s | `modelo-1`: otro modelo | **Últimas tendencias** |
| 6,8–12 s | Placa | **[X] CUOTAS SIN INTERÉS** / [bancos/tarjetas] / Hasta el 18/10 / James Craik · WhatsApp |

**Copy:**
> 🎁 DÍA DE LA MADRE en Óptica Vigliocco
> 💳 [X] cuotas sin interés con [bancos/tarjetas]
> 🕶️ Sol · 👓 Receta · Multifocales
> Promo válida hasta el 18/10. ¡Vení o escribinos!
> 📍 [dirección] · 💬 [WhatsApp]
>
> #DiaDeLaMadre #CuotasSinInteres #OpticaVigliocco #JamesCraik #Anteojos #Lentes

**Tip:** fijá un comentario con el link de WhatsApp. En la story que comparta este reel, sumá el sticker de enlace a WhatsApp.

---

## Reel 3: "¿Cuál le regalás?" (interacción, ~11 s)
**Objetivo:** comentarios para empujar el alcance y generar conversaciones por privado, que terminan en ventas.

| Tiempo | Toma | Texto |
|---|---|---|
| 0–2 s | `modelo-2` | **¿Cuál le regalás a mamá?** |
| 2–4 s | `modelo-3` | número grande **1** · *Sol* |
| 4–6 s | `modelo-4` | **2** · *Receta* |
| 6–8 s | `modelo-5` | **3** · *Multifocal* |
| 8–11 s | Placa | **Comentá 1, 2 o 3** · promo + vigencia · @opticavigliocco |

**Copy:**
> ¿1, 2 o 3? 👀 Contanos en los comentarios cuál le regalarías a mamá y te pasamos precio y cuotas por privado 💬
> 💳 [X] cuotas sin interés hasta el 18/10
>
> #DiaDeLaMadre #OpticaVigliocco #JamesCraik #RegaloParaMama

**Importante:** responder **todos** los comentarios dentro de la primera hora y mandar mensaje privado con precio y cuotas.

---

## Cómo se arman (técnico)
1. Copiar los videos a `clips/` como `modelo-1.mp4` … `modelo-5.mp4`, según la descripción de cada toma en `build-reels.sh`.
2. Completar `PROMO_TITULO`, `PROMO_DETALLE`, `PROMO_VIGENCIA` y `CONTACTO`. Opcional: `assets/logo.png`.
3. Ajustar el segundo de inicio de cada toma (2º argumento de `seg`) según los clips.
4. `./build-reels.sh` → genera `reels/*.mp4` + portadas `.jpg`.

**Al filmar o elegir clips:** que la modelo esté con buena luz natural, que no haya reflejos fuertes en los cristales y que la cara quede en el centro del cuadro. El 15% de arriba y de abajo lo tapa la interfaz de Instagram.
