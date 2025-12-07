note
	description: "[
		Cursor for iterating over SIMPLE_DATE_RANGE.

		Allows using `across` syntax:
			across range as d loop
				print (d.item.to_iso8601)
			end
		]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_DATE_RANGE_CURSOR

inherit
	ITERATION_CURSOR [SIMPLE_DATE]

create
	make

feature {NONE} -- Initialization

	make (a_start, a_end: SIMPLE_DATE)
			-- Initialize cursor for range.
		require
			start_not_void: a_start /= Void
			end_not_void: a_end /= Void
		do
			start_date := a_start
			end_date := a_end
			current_date := a_start
		ensure
			start_date_set: start_date = a_start
			end_date_set: end_date = a_end
		end

feature -- Access

	item: SIMPLE_DATE
			-- Current date in iteration.
		do
			Result := current_date
		end

feature -- Status

	after: BOOLEAN
			-- Has iteration finished?
		do
			Result := current_date.is_after (end_date)
		end

feature -- Cursor movement

	forth
			-- Move to next date.
		do
			current_date := current_date.plus_days (1)
		end

feature {NONE} -- Implementation

	start_date: SIMPLE_DATE
			-- Start of range.

	end_date: SIMPLE_DATE
			-- End of range.

	current_date: SIMPLE_DATE
			-- Current position in range.

invariant
	start_date_attached: start_date /= Void
	end_date_attached: end_date /= Void
	current_date_attached: current_date /= Void

end
