note
	description: "Summary description for {WSF_UPLOADED_FILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WSF_UPLOADED_FILE

inherit
	WSF_VALUE

create
	make

feature {NONE} -- Initialization	

	make (a_name: READABLE_STRING_8; n: like filename; t: like content_type; s: like size)
		do
			name := url_decoded_string (a_name)
			url_encoded_name := a_name
			filename := n
			content_type := t
			size := s
		end

feature -- Access

	name: READABLE_STRING_32

	url_encoded_name: READABLE_STRING_8

feature -- Element change

	change_name (a_name: like name)
		do
			name := url_decoded_string (a_name)
			url_encoded_name := a_name
		ensure then
			a_name.same_string (url_encoded_name)
		end


feature -- Status report

	is_string: BOOLEAN = False
			-- Is Current as a WSF_STRING representation?			


feature -- Conversion

	string_representation: STRING_32
		do
			Result := filename
		end

feature -- Visitor

	process (vis: WSF_VALUE_VISITOR)
		do
			vis.process_uploaded_file (Current)
		end

feature -- Access: Uploaded File

	filename: STRING
			-- original filename

	content_type: STRING
			-- Content type

	size: INTEGER
			-- Size of uploaded file

	tmp_name: detachable STRING
			-- Filename of tmp file

	tmp_basename: detachable STRING
			-- Basename of tmp file

feature -- Conversion

	safe_filename: STRING
		local
			fn: like filename
			c: CHARACTER
			i, n: INTEGER
		do
			fn := filename

				--| Compute safe filename, to avoid creating impossible filename, or dangerous one
			from
				i := 1
				n := fn.count
				create Result.make (n)
			until
				i > n
			loop
				c := fn[i]
				inspect c
				when '.', '-', '_' then
					Result.extend (c)
				when 'A' .. 'Z', 'a' .. 'z', '0' .. '9' then
					Result.extend (c)
				else
					inspect c
					when '%/192/' then Result.extend ('A') -- À
					when '%/193/' then Result.extend ('A') -- Á
					when '%/194/' then Result.extend ('A') -- Â
					when '%/195/' then Result.extend ('A') -- Ã
					when '%/196/' then Result.extend ('A') -- Ä
					when '%/197/' then Result.extend ('A') -- Å
					when '%/199/' then Result.extend ('C') -- Ç
					when '%/200/' then Result.extend ('E') -- È
					when '%/201/' then Result.extend ('E') -- É
					when '%/202/' then Result.extend ('E') -- Ê
					when '%/203/' then Result.extend ('E') -- Ë
					when '%/204/' then Result.extend ('I') -- Ì
					when '%/205/' then Result.extend ('I') -- Í
					when '%/206/' then Result.extend ('I') -- Î
					when '%/207/' then Result.extend ('I') -- Ï
					when '%/210/' then Result.extend ('O') -- Ò
					when '%/211/' then Result.extend ('O') -- Ó
					when '%/212/' then Result.extend ('O') -- Ô
					when '%/213/' then Result.extend ('O') -- Õ
					when '%/214/' then Result.extend ('O') -- Ö
					when '%/217/' then Result.extend ('U') -- Ù
					when '%/218/' then Result.extend ('U') -- Ú
					when '%/219/' then Result.extend ('U') -- Û
					when '%/220/' then Result.extend ('U') -- Ü
					when '%/221/' then Result.extend ('Y') -- Ý
					when '%/224/' then Result.extend ('a') -- à
					when '%/225/' then Result.extend ('a') -- á
					when '%/226/' then Result.extend ('a') -- â
					when '%/227/' then Result.extend ('a') -- ã
					when '%/228/' then Result.extend ('a') -- ä
					when '%/229/' then Result.extend ('a') -- å
					when '%/231/' then Result.extend ('c') -- ç
					when '%/232/' then Result.extend ('e') -- è
					when '%/233/' then Result.extend ('e') -- é
					when '%/234/' then Result.extend ('e') -- ê
					when '%/235/' then Result.extend ('e') -- ë
					when '%/236/' then Result.extend ('i') -- ì
					when '%/237/' then Result.extend ('i') -- í
					when '%/238/' then Result.extend ('i') -- î
					when '%/239/' then Result.extend ('i') -- ï
					when '%/240/' then Result.extend ('o') -- ð
					when '%/242/' then Result.extend ('o') -- ò
					when '%/243/' then Result.extend ('o') -- ó
					when '%/244/' then Result.extend ('o') -- ô
					when '%/245/' then Result.extend ('o') -- õ
					when '%/246/' then Result.extend ('o') -- ö
					when '%/249/' then Result.extend ('u') -- ù
					when '%/250/' then Result.extend ('u') -- ú
					when '%/251/' then Result.extend ('u') -- û
					when '%/252/' then Result.extend ('u') -- ü
					when '%/253/' then Result.extend ('y') -- ý
					when '%/255/' then Result.extend ('y') -- ÿ
					else
						Result.extend ('-')
					end
				end
				i := i + 1
			end
		end

feature -- Basic operation

	move_to (a_destination: STRING): BOOLEAN
			-- Move current uploaded file to `a_destination'
		require
			has_no_error: not has_error
		local
			f: RAW_FILE
		do
			if attached tmp_name as n then
				create f.make (n)
				if f.exists then
					f.change_name (a_destination)
					Result := True
				end
			end
		end

feature --  Status

	has_error: BOOLEAN
			-- Has error during uploading
		do
			Result := error /= 0
		end

	error: INTEGER
			-- Eventual error code
			--| no error => 0

feature -- Element change

	set_error (e: like error)
			-- Set `error' to `e'
		do
			error := e
		end

	set_tmp_name (n: like tmp_name)
			-- Set `tmp_name' to `n'
		do
			tmp_name := n
		end

	set_tmp_basename (n: like tmp_basename)
			-- Set `tmp_basename' to `n'
		do
			tmp_basename := n
		end

end