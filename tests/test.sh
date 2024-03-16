#
# Copyright 2024 axtloss <axtlos@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

check()
{
	local indent=../indent
	local tc=${1}

	sed -e '/\$FreeBSD.*\$/d' ${tc}.stdout > wanted_output.parsed
	wanted_checksum=$(sha1sum wanted_output.parsed | awk 'BEGIN {FS=" "}; {printf $1};')

	sed -e '/\$FreeBSD.*\$/d' ${tc} > input_file.parsed

	local profile_file="${tc}.pro"
	if [ -f "${profile_file}" ]; then
		profile_flag="-P${profile_file}"
	else
		# Make sure we don't implicitly use ~/.indent.pro from the test
		# host, for determinism purposes.
		profile_flag="-npro"
	fi
	

	echo "Running ${indent} ${profile_flag}"
	${indent} ${profile_flag} input_file.parsed output_file.parsed
	result_checksum=$(sha1sum output_file.parsed | awk 'BEGIN {FS=" "}; {printf $1};')

	if [[ "${result_checksum}" != "${wanted_checksum}" ]]; then
		echo "ERROR: check for ${tc} failed."
		exit 1
	else
		echo "SUCCESS: Check for ${tc} passed."
	fi
}

SRCDIR=$(pwd)

if [[ "$0" != "test.sh" ]]; then
	echo "Run this script from the tests directory"
	exit 1
fi

for path in $(find "${SRCDIR}" -regex '.*\.[0-9]+$'); do
	echo "found ${path}"
	check ${path##*/}
done

