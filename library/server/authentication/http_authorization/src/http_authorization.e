note
	description : "[
			Object representing Authorization http header
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=RFC2617 HTTP Authentication: Basic and Digest Access Authentication", "protocol=URI", "src=http://tools.ietf.org/html/rfc2617"
	EIS: "name=Wikipedia Basic Access Authentication", "protocol=URI", "src=http://en.wikipedia.org/wiki/Basic_access_authentication"
	EIS: "name=Wikipedia Digest Access Authentication", "protocol=URI", "src=http://en.wikipedia.org/wiki/Digest_access_authentication"

class
	HTTP_AUTHORIZATION

inherit
	REFACTORING_HELPER

	DEBUG_OUTPUT

create
	make,
	make_basic_auth,
	make_custom_auth

feature -- Initialization

	make (a_http_authorization: detachable READABLE_STRING_8)
			-- Initialize `Current'.
		local
			i, j: INTEGER
			t, s: STRING_8
			u,p: READABLE_STRING_32
			utf: UTF_CONVERTER
		do
			login := Void
			password := Void
			if a_http_authorization = Void then
					-- Default: Basic
				type := basic_auth_type
				http_authorization := Void
			else
				create http_authorization.make_from_string (a_http_authorization)
				create t.make_empty
				type := t
				if not a_http_authorization.is_empty then
					i := 1
					if a_http_authorization[i] = ' ' then
						i := i + 1
					end
					i := a_http_authorization.index_of (' ', i)
					if i > 0 then
						t.append (a_http_authorization.substring (1, i - 1))
						t.right_adjust; t.left_adjust
						if t.same_string (Basic_auth_type) then
							type := Basic_auth_type
							s := (create {BASE64}).decoded_string (a_http_authorization.substring (i + 1, a_http_authorization.count))
							i := s.index_of (':', 1) --| Let's assume ':' is forbidden in login ...
							if i > 0 then
								u := utf.utf_8_string_8_to_string_32 (s.substring (1, i - 1)) -- UTF_8 decoding to support unicode password
								p := utf.utf_8_string_8_to_string_32 (s.substring (i + 1, s.count)) -- UTF_8 decoding to support unicode password
								login := u
								password := p
								check
									(create {HTTP_AUTHORIZATION}.make_custom_auth (u, p, t)).http_authorization ~ http_authorization
								end
							end
						elseif t.same_string (Digest_auth_type) then
							type := Digest_auth_type

							-- XXX Why do we know here that a_http_authorization is attached?
							io.putstring ("Response: ---" + get_header_value_by_key (a_http_authorization, "response") + "---")
							io.new_line

							io.putstring ("Unquoted response: ---" + unquote_string(get_header_value_by_key (a_http_authorization, "response")) + "---")
							io.new_line


							io.putstring ("HTTP_AUTHORIZATION.make(): Digest Authorization. To be implemented.%N")
							to_implement ("HTTP Authorization %"digest%", not yet implemented")
						else
							to_implement ("HTTP Authorization %""+ t +"%", not yet implemented")
						end
					end
				end
			end
		ensure
			a_http_authorization /= Void implies http_authorization /= Void
		end

	make_basic_auth (u: READABLE_STRING_32; p: READABLE_STRING_32)
			-- Create a Basic authentication.
		do
			io.putstring ("HTTP_AUTHORIZATION.make_basic_auth()%N")

			make_custom_auth (u, p, Basic_auth_type)
		end

	make_custom_auth (u: READABLE_STRING_32; p: READABLE_STRING_32; a_type: READABLE_STRING_8)
			-- Create a custom `a_type' authentication.
		require
			a_type_accepted: a_type.is_case_insensitive_equal (Basic_auth_type)
							or a_type.is_case_insensitive_equal (Digest_auth_type)
		local
			t: STRING_8
			utf: UTF_CONVERTER
		do
			io.putstring ("HTTP_AUTHORIZATION.make_custom_auth()%N")

			login := u
			password := p
			create t.make_from_string (a_type)
			t.left_adjust; t.right_adjust
			type := t
			if t.is_case_insensitive_equal (Basic_auth_type) then
				type := Basic_auth_type
				create http_authorization.make_from_string ("Basic " + (create {BASE64}).encoded_string (utf.string_32_to_utf_8_string_8 (u + {STRING_32} ":" + p)))
			elseif t.is_case_insensitive_equal (Digest_auth_type) then
				type := Digest_auth_type
				to_implement ("HTTP Authorization %""+ t +"%", not yet implemented")
				create http_authorization.make_from_string (t + " ...NOT IMPLEMENTED")
			else
				to_implement ("HTTP Authorization %""+ t +"%", not yet implemented")
				create http_authorization.make_from_string ("Digest ...NOT IMPLEMENTED")
			end
		end

feature -- Access

	http_authorization: detachable IMMUTABLE_STRING_8

	type: READABLE_STRING_8

	login: detachable READABLE_STRING_32

	password: detachable READABLE_STRING_32

	realm_value: detachable READABLE_STRING_32

	nonce_value: detachable READABLE_STRING_32

	nc_value: detachable READABLE_STRING_32

	cnonce_value: detachable READABLE_STRING_32

	qop_value: detachable READABLE_STRING_32

	response_value: detachable READABLE_STRING_32

	opaque_value: detachable READABLE_STRING_32

feature -- Status report

	is_basic: BOOLEAN
			-- Is Basic authorization?
		do
			Result := type.is_case_insensitive_equal (Basic_auth_type)
		end

	is_digest: BOOLEAN
			-- Is Basic authorization?
		do
			Result := type.is_case_insensitive_equal (Digest_auth_type)
		end

	debug_output: STRING_32
			-- String that should be displayed in debugger to represent `Current'.
		do
			create Result.make_empty
			Result.append (type)
			Result.append (" ")
			if attached login as l_login then
				Result.append ("login=[")
				Result.append (l_login)
				Result.append ("] ")
			end
			if attached password as l_password then
				Result.append ("password=[")
				Result.append (l_password)
				Result.append ("] ")
			end
		end

feature -- Digest computation

	compute_hash_A1 (u: READABLE_STRING_8; r: READABLE_STRING_8; p: READABLE_STRING_8): STRING_8
			-- Compute H(A1).
			-- TODO When do we use which string class?
		local
--			hash: MD5
		do
			create Result.make_empty
		end

feature -- Access

	get_header_value_by_key(h: READABLE_STRING_8; k: STRING_8): STRING_8
			-- From header `h', get value associated to key `k'.
			-- Note: Response could be quoted.
		local
			i,j: INTEGER
		do
			i := h.substring_index (k, 1)

			if i = 0 then
				io.putstring ("Header " + h + " does not have a value associated to key " + k)
				create Result.make_empty
			else
				i := h.index_of ('=', i)
				j := h.index_of (',', i + 1)

				check
					not(i+1 > j-1 or i = 0 or j = 0)
				end

				Result := h.substring (i+1, j-1)
			end
		end

	unquote_string(s: STRING_8): STRING_8
			-- Returns string without quotes, or empty string if string is not quoted.
		local
			i, j: INTEGER
			rs: STRING_8
		do
			create rs.make_from_string (s)

			rs.left_adjust
			rs.right_adjust

			i := rs.index_of ('"', 1)
			j := rs.index_of ('"', i+1)

			if i+1 > j-1 or i = 0 or j = 0 then
				create Result.make_empty
			else
				Result := rs.substring (i+1, j-1)
			end
		end


feature -- Constants

	Basic_auth_type: STRING_8 = "Basic"
	Digest_auth_type: STRING_8 = "Digest"

invariant

	type_valid: (type.is_case_insensitive_equal (basic_auth_type) implies type = basic_auth_type)
				or (type.is_case_insensitive_equal (Digest_auth_type) implies type = Digest_auth_type)


end
