/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __BOARD_INTERFACES_H
#define __BOARD_INTERFACES_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include <stdint.h>
/* Private includes ----------------------------------------------------------*/

/* Exported types ------------------------------------------------------------*/

/* Exported constants --------------------------------------------------------*/

/* Exported macro ------------------------------------------------------------*/

/* Exported functions prototypes ---------------------------------------------*/
void iBoard_Init(void);
void iBoard_Wait(uint8_t aDelay);

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
