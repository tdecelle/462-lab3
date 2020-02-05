ruleset io.picolabs.twilio_v2 {
  meta {
    configure using account_sid = ""
                    auth_token = ""
    provides
        send_sms,
		messages
  }
 
  global {
    send_sms = defaction(to, from, message) {
       base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
       http:post(base_url + "Messages.json", form = {
                "From":from,
                "To":to,
                "Body":message
            })
    }

	messages = function(page_size, page, to, from) {
		base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
		page_size = page_size.klog("page_size: ").head()
		page = page.klog("page: ").head()
		to = to.klog("to: ").head()
		from = from.klog("from: ").head()

		pagination = 	(not page_size.isnull() && not page.isnull()) => "PageSize=" + page_size + "&Page=" + page |
						(not page_size.isnull() && page.isnull()) => "PageSize=" + page_size |
						(page_size.isnull() && not page.isnull()) => "Page=" + page | ""

		connect_params = (pagination == "") => "" | "&"

		request_form =	(not from.isnull() && not to.isnull()) => "From=" + from + "&To=" + to |
						(not from.isnull() && to.isnull()) => "From=" + from |
						(from.isnull() && not to.isnull()) => "To=" + to | ""

		prefix = (pagination == "" && request_form == "") => "" | "?"

		url = (base_url + "Messages.json" + prefix + pagination + connect_params + request_form).klog("URL: ").head()
		response = http:get(url, form = request_form)

		status = response{"status_code"};

		error_info = {
			"error": "Messages request was unsuccesful.",
			"httpStatus": {
				"code": status,
				"message": response{"status_line"}
			}
		};

		response_content = response{"content"}.decode();
		// response_error = (response_content.typeof() == "Map" && response_content{"error"}) => response_content{"error"} | 0;
		// response_error_str = (response_content.typeof() == "Map" && response_content{"error_str"}) => response_content{"error_str"} | 0;
		// error = error_info.put({"messagesError": response_error, "messagesErrorMsg": response_error_str, "messagesReturnValue": response_content});
		// is_bad_response = (response_content.isnull() || response_content == "null" || response_error || response_error_str);

		// (status == "200" && not is_bad_response) => response_content | error
		response_content
	}
  }
}
