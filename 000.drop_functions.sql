-- deprecada
drop function if exists sp_save_send_email_purchase /* funcion rota */
drop function if exists fnt_get_git_card_white_list;
-- no existen
drop function if exists fnt_find_git_card_x_dni;
drop function if exists fnt_get_user_data;
-- funciones a modificar
drop function if exists sp_list_order_internet;
drop function if exists sp_list_order_store;
drop function if exists sp_list_products_by_order;
drop function if exists sp_listar_detail_email_for_send;
drop function if exists sp_listar_email_for_send;
drop function if exists sp_listar_email_for_send_faild;
drop function if exists sp_listar_email_for_send_security;
drop function if exists sp_listar_order_detail_x_tikect;
drop function if exists sp_listar_order_details_x_order;
drop function if exists sp_listar_order_x_tikect;
drop function if exists sp_migra_order_detail_msa;
drop function if exists sp_migra_order_msa;
drop function if exists sp_save_email_option;
-- drop function if exists sp_save_order;
drop function if exists sp_save_send_email;
drop function if exists sp_save_send_email_security;
drop function if exists sp_save_state_done_msa;
drop function if exists sp_save_tikect_done_msa;
drop function if exists sp_update_qr;

