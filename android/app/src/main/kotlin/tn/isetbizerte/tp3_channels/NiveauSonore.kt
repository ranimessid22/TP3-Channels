package tn.isetbizerte.tp3_channels

import android.annotation.SuppressLint
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import kotlin.math.log10
import kotlin.math.sqrt

/**
 * Étape 4 : canal "audio/niveau" (EventChannel + coroutine).
 *
 * Exercice 3 (bonus) : au lieu d'envoyer ~20 valeurs/s (une par lecture du micro),
 * on n'envoie qu'UNE valeur toutes les [INTERVALLE_MS] millisecondes.
 */
class NiveauSonore(private val scope: CoroutineScope) : EventChannel.StreamHandler {

    private var job: Job? = null

    @SuppressLint("MissingPermission")   // Flutter demande la permission avant d'écouter
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        job = scope.launch(Dispatchers.IO) {                    // hors du thread principal
            val frequence = 44100
            val taille = AudioRecord.getMinBufferSize(
                frequence,
                AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT
            )
            val micro = AudioRecord(
                MediaRecorder.AudioSource.MIC, frequence,
                AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, taille
            )

            if (micro.state != AudioRecord.STATE_INITIALIZED) {
                micro.release()
                withContext(Dispatchers.Main) {
                    events.error("MICRO_INDISPONIBLE", "Micro indisponible ou permission refusée", null)
                }
                return@launch
            }

            val echantillons = ShortArray(taille)
            var dernierEnvoi = 0L                               // exercice 3 : instant du dernier envoi
            micro.startRecording()
            try {
                while (isActive) {                              // annulation coopérative (Ch.2)
                    val n = micro.read(echantillons, 0, echantillons.size)   // bloquant
                    if (n > 0) {
                        val maintenant = System.currentTimeMillis()
                        if (maintenant - dernierEnvoi >= INTERVALLE_MS) {    // exercice 3 : limiter le débit
                            dernierEnvoi = maintenant
                            val db = niveauDb(echantillons, n)
                            withContext(Dispatchers.Main) { events.success(db) }  // retour sur Main
                        }
                    }
                }
            } finally {
                micro.stop()
                micro.release()                                 // toujours libérer le micro
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        job?.cancel()          // isActive devient false → la boucle s'arrête → finally
        job = null
    }

    // Niveau efficace (RMS) converti en dBFS : 0 = maximum, -90 ≈ silence
    private fun niveauDb(s: ShortArray, n: Int): Double {
        var somme = 0.0
        for (i in 0 until n) somme += s[i].toDouble() * s[i]
        val rms = sqrt(somme / n)
        return if (rms > 0) 20 * log10(rms / Short.MAX_VALUE) else -90.0
    }

    companion object {
        /** Une valeur envoyée à Flutter toutes les 200 ms (≈ 5 valeurs/s au lieu de ≈ 20). */
        private const val INTERVALLE_MS = 200L
    }
}
