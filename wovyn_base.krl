ruleset wovyn_base {
	meta {
		use module io.picolabs.lesson_keys
		use module io.picolabs.twillio_v2 alias twilio
			with account_sid = 	keys:twilio{"account_sid"}
				 auth_token = 	keys:twilio{"auth_token"}

		shares __testing
	}

	global {
		__testing = {
			"queries": [],
			"events": []
		}
	}


	rule process_heartbeat {
		select when wovyn heartbeat

		send_directive("say", {"something": "Hello"})
	}
}
