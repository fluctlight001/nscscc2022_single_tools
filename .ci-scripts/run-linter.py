#!/usr/bin/env python3
from lxml import etree
import chardet
import sys
import os
from pathlib import Path
from typing import Tuple, List, Set
import shutil
import subprocess
import traceback

def is_header(f: Path):
    with f.open('rb') as fd:
        return -1 == fd.read().find(b'endmodule')

def transcoding(src: Path, target: Path):
    with src.open("rb") as fd:
        rawdata = fd.read()
        res = chardet.detect(rawdata)
        encoding = res['encoding'] if res['confidence'] > 0.5 else "GBK"
        try:
            s = rawdata.decode(encoding)
        except:
            print("Transcoding", src, ':')
            traceback.print_exc()
            s = rawdata.decode(encoding, 'replace')
        with target.open("wb") as wfd:
            wfd.write(s.encode('utf-8'))

def parse_project(xpr: Path) -> Tuple[str, Set[str], Set[str]]:
    prjname = os.path.splitext(xpr.name)[0]
    prjdir = xpr.parent
    srcdir = prjdir / (prjname + ".srcs")
    topname = ''
    target = prjdir / '.lint'

    tree = etree.parse(str(xpr))
    srclist = set()
    inclist = set()
    for fileset in tree.xpath("/Project/FileSets/FileSet"):
        if fileset.attrib['Type'] != 'DesignSrcs' and \
            fileset.attrib['Type'] != 'BlockSrcs':
            continue
        for child in fileset:
            if child.tag == 'File':
                tmp = child.attrib['Path']
                tmp = tmp.replace('$PSRCDIR', str(srcdir))
                tmp = tmp.replace('$PPRDIR', str(prjdir))
                tmp = tmp.replace(".xci", '_stub.v')
                vlog = Path(tmp)
                if not vlog.is_file():
                    print("Source file", vlog, "does not exist")
                    continue
                vlog_target = target / vlog.relative_to(prjdir)
                vlog_target.parent.mkdir(exist_ok=True, parents=True)
                # shutil.copy(vlog, vlog_target)
                transcoding(vlog, vlog_target)
                inclist.add(str(vlog_target.parent))
                if not is_header(vlog_target):
                    srclist.add(str(vlog_target))
            elif child.tag == 'Config' and fileset.attrib['Type'] == 'DesignSrcs':
                topname = child.xpath("./Option[@Name='TopModule']")[0].attrib['Val']
                
    return (topname, srclist, inclist)

def run_linter(prjdir: Path, topname: str, srclist: Set[str], inclist: Set[str]):
    linter_log = prjdir / "linter.log"
    args = ["verilator","--lint-only","-Wall","-Wno-DECLFILENAME","-Wno-PINCONNECTEMPTY","-Wno-UNUSED"]
    args += ['--top-module', topname]
    incargs = [ '-I' + i for i in inclist]
    args += incargs
    args += srclist
    # print(args)
    res = subprocess.run(args)
    if res.returncode != 0:
        print("Return code of verilator is", res.returncode)

if __name__ == "__main__":
    try:
        xpr = Path(sys.argv[1])
        topname, srclist, inclist = parse_project(xpr)
        run_linter(xpr.parent, topname, srclist, inclist)
    except:
        traceback.print_exc()

