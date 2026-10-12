#!/usr/bin/env bash
# Arma los 3 reels del Día de la Madre a partir de los clips de la modelo.
#
# Uso:  ./build-reels.sh            (lee clips/ y assets/, escribe en reels/)
#
# Antes de correr:
#   1. Copiar los videos de la modelo a clips/ con los nombres que usa cada
#      reel (ver la sección "MONTAJE" más abajo) o editar esos nombres.
#   2. Completar PROMO_* con los datos reales de la promo con tarjeta.
#   3. (Opcional) assets/logo.png con fondo transparente para la placa final.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CLIPS="$DIR/clips"
OUT="$DIR/reels"
LOGO="$DIR/assets/logo.png"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---- Datos del cliente (completar) -----------------------------------------
PROMO_TITULO="CUOTAS SIN INTERÉS"         # p.ej. "6 CUOTAS SIN INTERÉS"
PROMO_DETALLE="con tarjetas bancarias"     # p.ej. "Visa y Master · Banco X"
PROMO_VIGENCIA="Hasta el 18/10"
CONTACTO="James Craik · Escribinos por WhatsApp"
HANDLE="@opticavigliocco"

# ---- Estilo ------------------------------------------------------------------
W=1080; H=1920; FPS=30
FONT_BOLD="/usr/share/fonts/opentype/inter/Inter-Bold.otf"
FONT_REG="/usr/share/fonts/opentype/inter/Inter-Medium.otf"
FONT_SERIF="/usr/share/fonts/truetype/freefont/FreeSerifBoldItalic.ttf"
BG_COLOR="0xF4E9E4"     # rosa empolvado para placas
INK_COLOR="0x3A2A2A"    # texto sobre placas

# drawtext lee el texto de un archivo para no pelear con el escapado.
# (mktemp y no un contador: estas funciones corren dentro de subshells $(...))
tmpf() { mktemp -p "$TMP" "XXXXXX$1"; }
txt() { local f; f=$(tmpf .txt); printf '%s' "$1" > "$f"; echo "$f"; }

# Texto centrado con caja semitransparente. $1 texto, $2 y (expr), $3 tamaño,
# $4 fuente, $5 desde (s), $6 hasta (s).
dt() {
  local f; f=$(txt "$1")
  echo "drawtext=textfile='$f':fontfile='$4':fontsize=$3:fontcolor=white:\
box=1:boxcolor=black@0.35:boxborderw=24:line_spacing=12:\
x=(w-text_w)/2:y=$2:enable='between(t,$5,$6)':\
alpha='if(lt(t,$5+0.3),(t-$5)/0.3,1)'"
}

# Segmento de un clip: $1 archivo, $2 inicio, $3 duración, $4 filtros extra
# (drawtext separados por coma, o vacío), $5 velocidad (1 = normal, 0.7 = lento).
seg() {
  local src="$CLIPS/$1" ss="$2" d="$3" extra="${4:-}" speed="${5:-1}"
  local out; out=$(tmpf .mp4)
  [[ -f "$src" ]] || { echo "Falta clip: $src" >&2; exit 1; }
  local vf="setpts=PTS/$speed,scale=$W:$H:force_original_aspect_ratio=increase,crop=$W:$H,setsar=1,fps=$FPS"
  vf="$vf,eq=saturation=1.08:contrast=1.03"
  [[ -n "$extra" ]] && vf="$vf,$extra"
  local in_d; in_d=$(awk "BEGIN{print $d*$speed}")
  ffmpeg -loglevel error -y -ss "$ss" -t "$in_d" -i "$src" \
    -f lavfi -t "$d" -i anullsrc=r=44100:cl=stereo \
    -vf "$vf" -t "$d" -map 0:v -map 1:a \
    -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -c:a aac -shortest "$out"
  echo "$out"
}

# Placa final de color con textos y logo. $1 duración, $2 filtros drawtext.
card() {
  local d="$1" extra="$2" out; out=$(tmpf .mp4)
  if [[ -f "$LOGO" ]]; then
    ffmpeg -loglevel error -y -f lavfi -i "color=c=$BG_COLOR:s=${W}x${H}:r=$FPS:d=$d" \
      -i "$LOGO" -f lavfi -t "$d" -i anullsrc=r=44100:cl=stereo \
      -filter_complex "[1:v]scale=520:-1[lg];[0:v][lg]overlay=(W-w)/2:430,$extra,fade=in:st=0:d=0.3[v]" \
      -map "[v]" -map 2:a -t "$d" -c:v libx264 -crf 19 -pix_fmt yuv420p -c:a aac "$out"
  else
    local f; f=$(txt "ÓPTICA VIGLIOCCO")
    ffmpeg -loglevel error -y -f lavfi -i "color=c=$BG_COLOR:s=${W}x${H}:r=$FPS:d=$d" \
      -f lavfi -t "$d" -i anullsrc=r=44100:cl=stereo \
      -vf "drawtext=textfile='$f':fontfile='$FONT_BOLD':fontsize=78:fontcolor=$INK_COLOR:x=(w-text_w)/2:y=560,$extra,fade=in:st=0:d=0.3" \
      -map 0:v -map 1:a -t "$d" -c:v libx264 -crf 19 -pix_fmt yuv420p -c:a aac "$out"
  fi
  echo "$out"
}

# Texto sobre placa (color de tinta, sin caja).
ct() {
  local f; f=$(txt "$1")
  echo "drawtext=textfile='$f':fontfile='$4':fontsize=$3:fontcolor=$INK_COLOR:line_spacing=14:x=(w-text_w)/2:y=$2"
}

concat() {
  local out="$1"; shift
  local list; list=$(tmpf .txt)
  for s in "$@"; do echo "file '$s'" >> "$list"; done
  ffmpeg -loglevel error -y -f concat -safe 0 -i "$list" -c copy "$out"
  # Portada: primer frame con texto, 1 s adentro.
  ffmpeg -loglevel error -y -ss 1 -i "$out" -frames:v 1 -q:v 2 "${out%.mp4}-portada.jpg"
  echo "OK  $(basename "$out")  $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$out")s"
}

mkdir -p "$OUT"

# ============================ MONTAJE =========================================
# Nombres de clip esperados (renombrar los archivos o cambiar acá):
#   modelo-1.mp4  plano medio, la modelo se pone los lentes
#   modelo-2.mp4  primer plano / sonrisa a cámara
#   modelo-3.mp4  otro modelo de lentes (sol)
#   modelo-4.mp4  otro modelo de lentes (receta)
#   modelo-5.mp4  detalle / giro de cabeza
# Los tiempos de inicio (2º argumento de seg) se ajustan al ver los clips.

# --- Reel 1: emotivo (~13 s) ---
s1=$(seg modelo-1.mp4 0 3.5 "$(dt 'Ella te enseñó a mirar el mundo' 'h*0.70' 58 "$FONT_BOLD" 0.2 3.5)" 0.7)
s2=$(seg modelo-2.mp4 0 3.5 "$(dt 'Ahora regalale' 'h*0.70' 58 "$FONT_BOLD" 0.2 3.5)" 0.7)
s3=$(seg modelo-5.mp4 0 3   "$(dt 'una mirada nueva' 'h*0.70' 72 "$FONT_SERIF" 0.1 3)" 0.7)
c1=$(card 3 "$(ct 'Feliz Día, Mamá' 1000 84 "$FONT_SERIF"),$(ct "$HANDLE" 1500 44 "$FONT_REG")")
concat "$OUT/reel-1-emotivo.mp4" "$s1" "$s2" "$s3" "$c1"

# --- Reel 2: promo con tarjeta (~12 s) ---
s1=$(seg modelo-2.mp4 0 2   "$(dt 'DÍA DE LA MADRE' 'h*0.18' 70 "$FONT_BOLD" 0 2),$(dt "$PROMO_TITULO" 'h*0.70' 64 "$FONT_BOLD" 0.2 2)")
s2=$(seg modelo-3.mp4 0 1.6 "$(dt 'Sol' 'h*0.72' 64 "$FONT_BOLD" 0 1.6)")
s3=$(seg modelo-4.mp4 0 1.6 "$(dt 'Receta' 'h*0.72' 64 "$FONT_BOLD" 0 1.6)")
s4=$(seg modelo-1.mp4 1 1.6 "$(dt 'Últimas tendencias' 'h*0.72' 60 "$FONT_BOLD" 0 1.6)")
c1=$(card 5 "$(ct "$PROMO_TITULO" 980 70 "$FONT_BOLD"),$(ct "$PROMO_DETALLE" 1100 46 "$FONT_REG"),$(ct "$PROMO_VIGENCIA" 1180 46 "$FONT_REG"),$(ct "$CONTACTO" 1420 40 "$FONT_REG")")
concat "$OUT/reel-2-promo.mp4" "$s1" "$s2" "$s3" "$s4" "$c1"

# --- Reel 3: interacción "¿Cuál le regalás?" (~11 s) ---
s1=$(seg modelo-2.mp4 0 2   "$(dt '¿Cuál le regalás a mamá?' 'h*0.18' 62 "$FONT_BOLD" 0 2)")
s2=$(seg modelo-3.mp4 0 2   "$(dt '1' 'h*0.12' 160 "$FONT_BOLD" 0 2),$(dt 'Sol' 'h*0.72' 60 "$FONT_BOLD" 0 2)")
s3=$(seg modelo-4.mp4 0 2   "$(dt '2' 'h*0.12' 160 "$FONT_BOLD" 0 2),$(dt 'Receta' 'h*0.72' 60 "$FONT_BOLD" 0 2)")
s4=$(seg modelo-5.mp4 0 2   "$(dt '3' 'h*0.12' 160 "$FONT_BOLD" 0 2),$(dt 'Multifocal' 'h*0.72' 60 "$FONT_BOLD" 0 2)")
c1=$(card 3 "$(ct 'Comentá 1, 2 o 3' 1000 76 "$FONT_BOLD"),$(ct "$PROMO_TITULO · $PROMO_VIGENCIA" 1120 42 "$FONT_REG"),$(ct "$HANDLE" 1500 44 "$FONT_REG")")
concat "$OUT/reel-3-interaccion.mp4" "$s1" "$s2" "$s3" "$s4" "$c1"
