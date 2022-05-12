
USE [GIFTCARD]
GO
/****** Object:  StoredProcedure [giftcard].[GCV_PRC_RESTET_TRANSACTION_GIFTCARD_VIRTUAL]    Script Date: 12/05/2022 9:17:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--****************************************************************************************
--Descripcion: Store procedure que realiza el reseteo de la transaccion de una giftcard borrando los registros relacionados al authcode(este es un codigo unico)

--Input Parameters:
--@p_auth_code numeric,

--Output Parameters:
-- 
--Autor: Maximo Apaza
--Proyecto : RQ 4707 - 4
--Responsable: Gianmarcos Perez
--RDC: RQ 4707 - 4

--Revisiones
---------------------------------------------------------------------------------------
--Fecha			Autor				Motivo de cambio		  RDC
---------------------------------------------------------------------------------------
--12/05/2022	Maximo Apaza		Creacion de la funcion  RQ 4707 - 4
---------------------------------------------------------------------------------------
--***************************************************************************************
ALTER PROCEDURE [giftcard].[GCV_PRC_CRRESTETRANSACTION_GIFTCARD_VIRTUAL](@p_auth_code numeric)
AS
BEGIN
	SET NOCOUNT ON;
        delete from [giftcard].[GiftcardEvents] where [trxHeader] = @p_auth_code;
        delete from [giftcard].[GiftcardTrxItems] where [trxID] = @p_auth_code;
        delete from [giftcard].[GiftcardTrxHeader] where [id]= @p_auth_code;

	BEGIN TRAN GIFTCARD
		
		
	COMMIT TRAN GIFTCARD

END
