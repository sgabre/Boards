/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __LED_INTERFACES_H
#define __LED_INTERFACES_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/

/* Private includes ----------------------------------------------------------*/

/* Exported types ------------------------------------------------------------*/

/* Exported constants --------------------------------------------------------*/
typedef enum 
{
	eRED_LED,
	eNUMBER_OF_LED	
}eLed;
/* Exported macro ------------------------------------------------------------*/

/* Exported functions prototypes ---------------------------------------------*/
void iLed_Init(void);
void iLed_On(eLed aLed);
void iLed_Off(eLed aLed);
void iLed_Toggle(eLed aLed);

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
