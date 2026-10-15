#include "sys/alt_stdio.h"
#include "system.h"
#include "alt_types.h"
#include <stdio.h>
#include <unistd.h>

/* Horloge du SOPC */
#define CLK 50000000

/* Composant avalon_pwm
 *   freq    : periode en coups d'horloge, f = CLK / freq
 *   duty    : nombre de coups a l'etat haut
 *   control : b0 raz_n, b1 enable
 */
#define pwm_freq    (unsigned int *) (AVALON_PWM_0_BASE + 0)
#define pwm_duty    (unsigned int *) (AVALON_PWM_0_BASE + 4)
#define pwm_control (unsigned int *) (AVALON_PWM_0_BASE + 8)

#define PWM_RAZ_N   0x00000001
#define PWM_ENABLE  0x00000002

/* Composant avalon_anemometre
 *   config : b0 raz_n, b1 continu, b2 start_stop
 *   code   : b9 valid, b7..b0 data
 */
#define ane_config (unsigned int *) (AVALON_ANEMOMETRE_0_BASE + 0)
#define ane_code   (unsigned int *) (AVALON_ANEMOMETRE_0_BASE + 4)

#define ANE_RAZ_N      0x00000001
#define ANE_CONTINU    0x00000002
#define ANE_START_STOP 0x00000004

#define ANE_VALID      0x00000200
#define ANE_DATA       0x000000FF

char buffer[20];

void regler_pwm(unsigned int hz)
{
    unsigned int periode = CLK / hz;

    *pwm_freq    = periode;
    *pwm_duty    = periode / 2;
    *pwm_control = PWM_RAZ_N | PWM_ENABLE;
}

void afficher(const char *texte, int valeur)
{
    sprintf(buffer, "%d", valeur);
    alt_putstr(texte);
    alt_putstr(buffer);
}

int main()
{
    unsigned int consignes[6] = {10, 25, 50, 100, 200, 250};
    unsigned int lecture;
    int i;

    alt_putstr("\nValidation SOPC : PWM bouclee sur l'anemometre\n");
    alt_putstr("consigne (Hz) | mesure (Hz) | ecart\n");

    *ane_config = 0;
    usleep(1000);
    *ane_config = ANE_RAZ_N | ANE_CONTINU;

    for (i = 0; i < 6; i++) {

        regler_pwm(consignes[i]);

        /* deux fenetres de mesure pour etre sur d'en avoir une complete */
        usleep(2500000);

        lecture = *ane_code;

        afficher("      ", (int)consignes[i]);
        afficher("    |      ", (int)(lecture & ANE_DATA));
        afficher("    |   ", (int)(lecture & ANE_DATA) - (int)consignes[i]);
        alt_putstr("\n");
    }

    alt_putstr("\nMesure en continu\n");

    regler_pwm(100);

    while (1) {

        lecture = *ane_code;

        if (lecture & ANE_VALID) {
            afficher("Vent : ", (int)(lecture & ANE_DATA));
            alt_putstr(" Hz\n");
        }

        usleep(500000);
    }

    return 0;
}
