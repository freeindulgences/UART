#include "mcu_support_package/inc/stm32f10x.h"


void initUart1()
{
	
	GPIO_InitTypeDef  gpioStructA9; // настройка первой ноги TX USART1
	
	gpioStructA9.GPIO_Mode = GPIO_Mode_AF_PP; 
	gpioStructA9.GPIO_Pin = GPIO_Pin_9; 
	gpioStructA9.GPIO_Speed = GPIO_Speed_10MHz;
	
	GPIO_Init( GPIOA, &gpioStructA9);
	
	
	GPIO_InitTypeDef  gpioStructA10; // настройка первой ноги RX USART1
	
	gpioStructA10.GPIO_Mode = GPIO_Mode_IN_FLOATING; 
	gpioStructA10.GPIO_Pin = GPIO_Pin_10; 
	gpioStructA10.GPIO_Speed = GPIO_Speed_10MHz;
	
	GPIO_Init( GPIOA, &gpioStructA10);
	// вывод 9 -альтернативный выход для Tx, а 10 вывод – вход Rx
	
	USART_InitTypeDef USART_InitStructure;
	
	//RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);//Разрешаем тактирование
	
	USART_InitStructure.USART_BaudRate = 9600;// скорость
	USART_InitStructure.USART_WordLength = USART_WordLength_8b; //8 бит данных
	USART_InitStructure.USART_StopBits = USART_StopBits_1; //один стоп бит
	USART_InitStructure.USART_Parity = USART_Parity_No; //четность - нет
	USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None; // управлени потоком - нет
	USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;  // разрешаем прием и передачу
	
	USART_Init(USART1, &USART_InitStructure); //инизиализируем
	USART_Cmd(USART1, ENABLE);
	
}

void send_Uart() // отправить байт
{
	//Проверяем буфер передатчика
	while(!USART_GetFlagStatus(USART1, USART_FLAG_TXE));
	
	// отправляем по uart единичку, если кнопка нажата, и 0, если не нажата
	USART_SendData(USART1, GPIO_ReadInputDataBit(GPIOA, GPIO_Pin_0)); 
}
	
int main(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
	
	GPIO_InitTypeDef  gpioStructC; // светодиод
	
	gpioStructC.GPIO_Mode = GPIO_Mode_Out_PP; //выход в режиме push pull
	gpioStructC.GPIO_Pin = GPIO_Pin_8; 
	gpioStructC.GPIO_Speed = GPIO_Speed_10MHz;
	
	GPIO_Init( GPIOC, &gpioStructC);
		
	GPIO_InitTypeDef  gpioStructA; // кнопка
	
	gpioStructA.GPIO_Mode = GPIO_Mode_IN_FLOATING; //вход с подтяжкой вверх						
	gpioStructA.GPIO_Pin = GPIO_Pin_0; 
	gpioStructA.GPIO_Speed = GPIO_Speed_10MHz;
	
	GPIO_Init( GPIOA, &gpioStructA);	
	
	initUart1(); 
	
	while(1)
	{			
		if(GPIO_ReadInputDataBit(GPIOA, GPIO_Pin_0) == 1) // если кнопка нажата
		{  
			send_Uart();
		}	

		if (USART_GetFlagStatus(USART1, USART_FLAG_RXNE)) 
		{
			if(USART_ReceiveData(USART1) == 1) // если пришла 1, значит кнопка нажата
			{
				GPIO_SetBits(GPIOC, GPIO_Pin_8); // включаем светодиод
			}
			else
			{
				GPIO_ResetBits(GPIOC, GPIO_Pin_8); // выключаем светодиод
			}
		}

		//пуст ли отправной буфер (в данный момент байт не передается)
		if(USART_GetFlagStatus(USART1, USART_FLAG_TXE) == 1)
		{
			USART_SendData(USART1, GPIO_ReadInputDataBit(GPIOA, GPIO_Pin_0));
		}
	}
	return 0;
}




#ifdef USE_FULL_ASSERT

// эта функция вызывается, если assert_param обнаружил ошибку
void assert_failed(uint8_t * file, uint32_t line)
{ 
	/* User can add his own implementation to report the file name and line number,
	ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
	
	(void)file;
	(void)line;
	
	__disable_irq();
	while(1)
	{
		// это ассемблерная инструкция "отладчик, стой тут"
		// если вы попали сюда, значит вы ошиблись в параметрах вызова функции из SPL. 
		// Смотрите в call stack, чтобы найти ее
		__BKPT(0xAB);
	}
}

#endif
