#!/usr/bin/env python
"""
tcsteg -- TrueCrypt real steganography tool
version 1.0 (2011-02-24)
by Martin J. Fiedler <martin.fiedler@gmx.net>

This software is published under the terms of KeyJ's Research License,
version 0.2. Usage of this software is subject to the following conditions:
0. There's no warranty whatsoever. The author(s) of this software can not
   be held liable for any damages that occur when using this software.
1. This software may be used freely for both non-commercial and commercial
   purposes.
2. This software may be redistributed freely as long as no fees are charged
   for the distribution and this license information is included.
3. This software may be modified freely except for this license information,
   which must not be changed in any way.
4. If anything other than configuration, indentation or comments have been
   altered in the code, the original author(s) must receive a copy of the
   modified code.
"""
import sys, os, array

def r_u32(s, offs=0):
    return (ord(s[offs]) << 24) | (ord(s[offs+1]) << 16) | (ord(s[offs+2]) << 8) | ord(s[offs+3])
def w_u32(i):
    return chr((i >> 24) & 0xFF) + chr((i >> 16) & 0xFF) + chr((i >> 8) & 0xFF) + chr(i & 0xFF)

LITTLE_ENDIAN = array.array('h', "\x00\x01").tolist()[0] - 1

def copy_block(f_src, f_dest, size):
    BLOCKSIZE = 65536
    while size > 0:
        bytes = size
        if bytes > BLOCKSIZE:
            bytes = BLOCKSIZE
        block = f_src.read(bytes)
        if not block:
            break
        f_dest.write(block)
        size -= len(block)
    return size

class ProcessingError(RuntimeError):
    pass

################################################################################

class QTFileAtom:
    def __init__(self, atom_or_file=None, offset=0, size=0):
        self.offset = offset
        if isinstance(atom_or_file, basestring):
            self.atom = atom_or_file
            self.size = size
        else:
            atom_or_file.seek(offset)
            s = atom_or_file.read(8)
            if len(s) < 8:
                raise EOFError("end of file reached")
            self.size = r_u32(s)
            self.atom = s[4:]
            if not self.size:
                atom_or_file.seek(0, 2)
                self.size = atom_or_file.tell() - offset
            elif self.size == 1:
                raise ValueError("64-bit files are not supported")
        self.end = self.offset + self.size

    def read(self, f):
        f.seek(self.offset)
        data = f.read(self.size)
        if len(data) != self.size:
            raise IOError("unexpected end of file")
        return data

    def copy(self, f_src, f_dest, payload_only=False):
        offset = self.offset
        size = self.size
        if payload_only:
            offset += 8
            size -= 8
        f_src.seek(offset)
        if copy_block(f_src, f_dest, size):
            raise IOError("unexpected end of file")

    def copy_moov(self, f_src, f_dest, offset_adjust=0):
        moov = self.read(f_src)
        stco_pos = 0
        while True:
            stco_pos = moov.find("stco\0\0\0\0", stco_pos + 5) - 4
            if stco_pos <= 0:
                break
            stco_size = r_u32(moov, stco_pos)
            stco_count = r_u32(moov, stco_pos + 12)
            if stco_size < (stco_count * 4 + 16):
                continue  # invalid stco size, maybe a false positive
            start = stco_pos + 16
            end = start + stco_count * 4
            data = array.array('I', moov[start:end])
            if LITTLE_ENDIAN: data.byteswap()
            try:
                data = array.array('I', [x + offset_adjust for x in data])
            except OverflowError:
                continue  # invalid offset, maybe a false positive
            if LITTLE_ENDIAN: data.byteswap()
            moov = moov[:start] + data.tostring() + moov[end:]
        f_dest.write(moov)

    def __repr__(self):
        return "QTFileAtom(%r, %d, %d)" % (self.atom, self.offset, self.size)

def AnalyzeQT(f):
    relevant_atoms = ('ftyp', 'moov', 'mdat')
    atoms = {}
    offset = 0
    while True:
        try:
            atom = QTFileAtom(f, offset)
        except EOFError:
            break
        if atom.atom in relevant_atoms:
            if atom.atom in atoms:
                raise ValueError("duplicate %r atom" % atom.atom)
            atoms[atom.atom] = atom
        elif not(atom.atom in ('free', 'wide', 'uuid')):
            print >>sys.stderr, "WARNING: unknown atom %r, ignoring" % atom.atom
        offset = atom.end
    try:
        return tuple([atoms[a] for a in relevant_atoms])
    except KeyError:
        raise ValueError("missing '%s' atom" % atom)

def TCSteg_Embed_QT(f_src, f_dest):
    "QuickTime / ISO MPEG-4 ### mov,qt,mp4,m4v,m4a"
    try:
        ftyp, moov, mdat = AnalyzeQT(f_src)
    except (IOError, ValueError), e:
        print >>sys.stderr, "Error reading the source file:", e
        return 1
    if ftyp.size > (65536 - 8):
        raise ProcessingError("'ftyp' atom too long")

    # copy main data
    f_dest.seek(0, 2)
    eof_pos = f_dest.tell() - 131072
    if eof_pos <= 131072:
        raise ProcessingError("TrueCrypt file too small")
    f_dest.seek(eof_pos)
    if (eof_pos + mdat.size - 8 + moov.size) >= (2L**32):
        raise ProcessingError("files too large (must be less than 4 GiB)")
    mdat.copy(f_src, f_dest, payload_only=True)
    mdat_end = f_dest.tell()
    moov.copy_moov(f_src, f_dest, eof_pos - mdat.offset - 8)

    # re-generate first 64 KiB
    head = ftyp.read(f_src) + "\0\0\0\x08free"
    head += w_u32(mdat_end - len(head)) + "mdat"
    f_dest.seek(0)
    f_dest.write(head)
    remain = 65536 - len(head)
    if remain >= 0:
        f_src.seek(mdat.offset + 8)
        f_dest.write(f_src.read(remain))

    return 0

################################################################################

def __get_fmts():
    return [item for name, item in globals().iteritems() if name.lower().startswith('tcsteg_embed_')]
FORMATS = __get_fmts()

if __name__ == "__main__":
    try:
        f_src = sys.argv[1]
        f_dest = sys.argv[2]
    except IndexError:
        print "Usage:", sys.argv[0], "<INPUT> <OUTPUT>"
        print "Embeds a file into a TrueCrypt container so that both are still readable."
        print
        print "<INPUT> is a file in one of the following formats:"
        fmtlist = []
        for fmt in FORMATS:
            name, exts = fmt.__doc__.split("###", 1)
            exts = exts.strip().lower().split(',')
            exts.sort()
            fmtlist.append((name.strip(), exts))
        maxlen = max([len(name) for name, exts in fmtlist])
        for name, exts in fmtlist:
            print "    %s  (%s)" % (name.ljust(maxlen), ", ".join(["*."+ext for ext in exts]))
        print
        print "<OUTPUT> is a TrueCrypt container containing a hidden volume. The file will be"
        print "modified in-place so that it seems like a copy of the input file that can be"
        print "opened in an appropriate viewer/player. However, the hidden TrueCtype volume"
        print "will also be preserved and can be used."
        print

    main = None
    ext = os.path.splitext(f_src)[-1][1:].lower()
    for fmt in FORMATS:
        if ext in fmt.__doc__.split("###", 1)[-1].strip().lower().split(','):
            main = fmt
    if not main:
        print >>sys.stderr, "Error: input file format is not supported"
        sys.exit(1)

    try:
        f_src = open(f_src, "rb")
    except IOError, e:
        print >>sys.stderr, "Error opening the input file:", e
        sys.exit(1)
    try:
        f_dest = open(f_dest, "r+b")
    except IOError, e:
        print >>sys.stderr, "Error opening the output file:", e
        sys.exit(1)

    try:
        sys.exit(main(f_src, f_dest))
    except ProcessingError, e:
        print >>sys.stderr, "Error:", e
        sys.exit(1)

