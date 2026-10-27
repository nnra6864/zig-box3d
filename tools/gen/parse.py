"""Parses the Box3D public headers into a flat list of declarations."""

import re
from dataclasses import dataclass, field


@dataclass
class Field:
    ctype: str
    name: str
    array: str | None
    doc: list[str]


@dataclass
class Param:
    ctype: str
    name: str


@dataclass
class Decl:
    kind: str  # struct, enum, func, callback, opaque
    cname: str
    doc: list[str]
    group: str
    header: str
    fields: list[Field] = field(default_factory=list)
    values: list[tuple[str, str | None, list[str]]] = field(default_factory=list)
    ret: str = ""
    params: list[Param] = field(default_factory=list)
    raw: str = ""


def strip_doc(line: str) -> str:
    line = line.strip()
    for p in ("///<", "///", "//!<", "//"):
        if line.startswith(p):
            line = line[len(p):]
            break
    if line.startswith(" ") or line.startswith("\t"):
        line = line[1:]
    return line.rstrip()


def split_params(s: str) -> list[Param]:
    s = s.strip()
    if s in ("", "void"):
        return []
    out = []
    for p in s.split(","):
        p = p.strip()
        m = re.match(r"(.*?)([A-Za-z_]\w*)\s*(\[\s*\d*\s*\])?$", p)
        ctype, name, arr = m.group(1).strip(), m.group(2), m.group(3)
        if arr:
            ctype += "*"
        if not ctype:  # unnamed
            ctype, name = name, f"arg{len(out)}"
        out.append(Param(ctype, name))
    return out


def parse_fields(body: str) -> list[Field]:
    fields = []
    doc: list[str] = []
    for line in body.split("\n"):
        s = line.strip()
        if not s:
            continue
        if s.startswith("///") or (s.startswith("//") and not s.startswith("//!")):
            if s.startswith("///"):
                doc.append(strip_doc(s))
            continue
        m = re.match(r"([^;]+);\s*(.*)$", s)
        if not m:
            raise ValueError(f"cannot parse field line: {s!r}")
        decl, trailing = m.group(1), m.group(2)
        tdoc = []
        if trailing.startswith("//"):
            t = strip_doc(trailing)
            if t:
                tdoc = [t]
        parts = [p.strip() for p in decl.split(",")]
        first = re.match(r"(.*?)([A-Za-z_]\w*)\s*(\[\s*\w+\s*\])?$", parts[0])
        ctype = first.group(1).strip()
        names = [(first.group(2), first.group(3))]
        for p in parts[1:]:
            mm = re.match(r"([A-Za-z_]\w*)\s*(\[\s*\w+\s*\])?$", p)
            if not mm: raise ValueError(repr(s))
            names.append((mm.group(1), mm.group(2)))
        for name, arr in names:
            a = arr.strip("[] ") if arr else None
            fields.append(Field(ctype, name, a, doc + tdoc))
        doc = []
    return fields


def parse_enum(body: str):
    values = []
    doc: list[str] = []
    for line in body.split("\n"):
        s = line.strip()
        if not s:
            continue
        if s.startswith("///"):
            doc.append(strip_doc(s))
            continue
        m = re.match(r"(\w+)\s*(?:=\s*([^,]+?))?\s*,?\s*(//.*)?$", s)
        if not m:
            raise ValueError(f"cannot parse enum line: {s!r}")
        tdoc = [strip_doc(m.group(3))] if m.group(3) else []
        values.append((m.group(1), m.group(2), doc + tdoc))
        doc = []
    return values


def parse_header(path: str, header: str) -> list[Decl]:
    text = open(path).read()
    lines = text.split("\n")
    decls: list[Decl] = []
    doc: list[str] = []
    group_stack: list[str] = []
    pp_depth = 0
    i = 0

    def cur_group(d):
        for line in d:
            m = re.search(r"@ingroup (\w+)", line)
            if m:
                return m.group(1)
        return group_stack[-1] if group_stack else header

    while i < len(lines):
        line = lines[i]
        s = line.strip()
        i += 1

        # Preprocessor conditionals: everything inside is written by hand.
        if s.startswith("#if"):
            pp_depth += 1
            doc = []
            continue
        if s.startswith("#endif"):
            pp_depth -= 1
            continue
        if pp_depth > 0:
            continue
        if s.startswith("#"):
            while line.rstrip().endswith("\\"):
                line = lines[i]
                i += 1
            doc = []
            continue

        if s.startswith("/**") or s.startswith("/*"):
            block = s
            while "*/" not in block:
                block += "\n" + lines[i]
                i += 1
            m = re.search(r"@(?:defgroup|addtogroup) (\w+)", block)
            if m and "@{" in block:
                group_stack.append(m.group(1))
            elif "@}" in block and group_stack:
                group_stack.pop()
            doc = []
            continue
        if s.startswith("//!"):
            continue
        if s.startswith("///"):
            doc.append(strip_doc(s))
            continue
        if s.startswith("//") or not s:
            if not s:
                doc = []
            continue

        # Gather a full statement.
        stmt = s
        if s.startswith(("B3_INLINE", "B3_FORCE_INLINE", "B3_ID_INLINE")):
            # Skip inline function bodies.
            depth = stmt.count("{") - stmt.count("}")
            seen = "{" in stmt
            while not seen or depth > 0:
                l2 = lines[i]
                i += 1
                depth += l2.count("{") - l2.count("}")
                seen = seen or "{" in l2
            doc = []
            continue

        if s.startswith("typedef struct") or s.startswith("typedef enum") or s.startswith("typedef union"):
            if s.endswith(";") and "{" not in s:
                m = re.match(r"typedef struct (\w+) (\w+);", s)
                decls.append(Decl("opaque", m.group(2), doc, cur_group(doc), header))
                doc = []
                continue
            depth = 0
            buf = [s]
            depth += s.count("{") - s.count("}")
            started = "{" in s
            while not started or depth > 0:
                l2 = lines[i]
                i += 1
                buf.append(l2)
                depth += l2.count("{") - l2.count("}")
                started = started or "{" in l2
            # closing line holds the name
            tail = buf[-1].strip()
            while not tail.endswith(";"):
                tail += lines[i].strip()
                i += 1
            name = re.match(r"}\s*(\w+)\s*;", tail).group(1)
            body = "\n".join(buf)
            inner = body[body.index("{") + 1: body.rindex("}")]
            kind = "enum" if s.startswith("typedef enum") else "struct"
            d = Decl(kind, name, doc, cur_group(doc), header, raw=body)
            if kind == "enum":
                d.values = parse_enum(inner)
            else:
                if "union" in inner or re.search(r"\(\s*\*", inner):
                    d.kind = "struct_manual"
                else:
                    d.fields = parse_fields(inner)
            decls.append(d)
            doc = []
            continue

        if s.startswith("typedef"):
            while not stmt.endswith(";"):
                stmt += " " + lines[i].strip()
                i += 1
            m = re.match(r"typedef\s+(.+?)\s*\b(\w+)\s*\((.*)\)\s*;", stmt)
            if m:
                d = Decl("callback", m.group(2), doc, cur_group(doc), header)
                d.ret = m.group(1).strip()
                d.params = split_params(m.group(3))
                decls.append(d)
            doc = []
            continue

        if s.startswith("B3_API"):
            while not stmt.endswith(";"):
                stmt += " " + lines[i].strip()
                i += 1
            m = re.match(r"B3_API\s+(.+?)\s*\b(\w+)\s*\((.*)\)\s*;", stmt)
            d = Decl("func", m.group(2), doc, cur_group(doc), header)
            d.ret = m.group(1).strip()
            d.params = split_params(m.group(3))
            decls.append(d)
            doc = []
            continue

        if s.startswith("static const"):
            while not stmt.endswith(";"):
                stmt += lines[i].strip()
                i += 1
            doc = []
            continue

        raise ValueError(f"{header}: unhandled line {s!r}")
    return decls
