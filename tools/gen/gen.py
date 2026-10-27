"""Generates the Zig bindings in src/box3d/ from the Box3D headers.

Usage: python3 -I tools/gen/gen.py zig-pkg/<box3d package>/include/box3d src

src/box3d/math.zig and src/box3d/constants.zig are written by hand, everything else
in src/ (except smoke_test.zig) is generated. Hand written pieces live in overrides.py.
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from parse import parse_header, Decl  # noqa: E402
import overrides as ov  # noqa: E402

INC = sys.argv[1]
OUT = sys.argv[2]


def pubs_of(path):
    return re.findall(r"^pub (?:const|fn) (\w+)", open(path).read(), re.M)


ov.MATH_PUBS = pubs_of(os.path.join(OUT, "box3d", "math.zig"))
ov.CONSTANT_PUBS = pubs_of(os.path.join(OUT, "box3d", "constants.zig"))

HEADERS = ["base", "id", "types", "collision", "box3d"]

decls: list[Decl] = []
for h in HEADERS:
    decls += parse_header(os.path.join(INC, h + ".h"), h)

by_name = {d.cname: d for d in decls}

# ---------------------------------------------------------------- names

ID_TYPES = {
    "b3WorldId": "World",
    "b3BodyId": "Body",
    "b3ShapeId": "Shape",
    "b3JointId": "Joint",
    "b3ContactId": "Contact",
}

JOINT_KINDS = ["Distance", "Motor", "Filter", "Parallel", "Prismatic", "Revolute", "Spherical", "Weld", "Wheel"]


def zig_type_name(c: str) -> str:
    if c in ID_TYPES:
        return ID_TYPES[c]
    if c in ov.TYPE_RENAMES:
        return ov.TYPE_RENAMES[c]
    assert c.startswith("b3"), c
    return c[2:]


def lower_first(s: str) -> str:
    # Keep leading acronyms readable: AABB -> aabb, TOI -> toi
    m = re.match(r"([A-Z]+)([A-Z][a-z].*)?$", s)
    if m and len(m.group(1)) > 1:
        return m.group(1).lower() + (m.group(2) or "")
    return s[0].lower() + s[1:]


def snake(s: str) -> str:
    s = re.sub(r"([a-z])([A-Z])", r"\1_\2", s)
    s = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1_\2", s)
    return s.lower()


OWNER_PREFIXES = {
    "World": "World",
    "Body": "Body",
    "Shape": "Shape",
    "Joint": "Joint",
    "Contact": "Contact",
    "Recording": "Recording",
    "RecPlayer": "RecPlayer",
    "DynamicTree": "DynamicTree",
}
for k in JOINT_KINDS:
    OWNER_PREFIXES[k + "Joint"] = k + "Joint"


def owner_of(d: Decl):
    """Returns (owner type, method name, also flat) for a function."""
    if d.cname in ov.OWNERS:
        return ov.OWNERS[d.cname]
    m = re.match(r"b3(\w+?)_(\w+)$", d.cname)
    if m and m.group(1) in OWNER_PREFIXES:
        return OWNER_PREFIXES[m.group(1)], lower_first(m.group(2)), None
    m = re.match(r"b3Default(\w+)$", d.cname)
    if m:
        return zig_type_name("b3" + m.group(1)), "default", "default" + m.group(1)
    return None, lower_first(d.cname[2:]), None


# file assignment
GROUP_FILES = {
    "base": "base",
    "constants": "constants",
    "math": "math",
    "world": "world",
    "event": "events",
    "recording": "recording",
    "body": "body",
    "shape": "shape",
    "joint": "joint",
    "contact": "contact",
    "query": "query",
    "tree": "tree",
    "character": "mover",
    "geometry": "geometry",
    "sphere": "geometry",
    "capsule": "geometry",
    "hull": "geometry",
    "mesh": "geometry",
    "height_field": "geometry",
    "compound": "geometry",
    "collision": "collision",
    "debug_draw": "debug_draw",
    "types": "debug_draw",
}
for k in JOINT_KINDS:
    GROUP_FILES[k.lower() + "_joint"] = "joint"

ID_FILES = {"b3WorldId": "world", "b3BodyId": "body", "b3ShapeId": "shape", "b3JointId": "joint", "b3ContactId": "contact"}


def file_of(d: Decl) -> str:
    if d.cname in ov.FILES:
        return ov.FILES[d.cname]
    if d.cname in ID_FILES:
        return ID_FILES[d.cname]
    return GROUP_FILES[d.group]


# Skipped declarations: written by hand or not useful from Zig.
SKIP = set(ov.SKIP)


def keep(d: Decl) -> bool:
    if d.cname in SKIP:
        return False
    if d.kind == "opaque" and d.cname not in ov.OPAQUES:
        return False
    return True


emitted = [d for d in decls if keep(d)]

# Map of every C name to its Zig spelling, for doc comments.
name_map: dict[str, str] = {}
owners: dict[str, tuple] = {}
for d in emitted:
    if d.kind == "func":
        o, mname, flat = owner_of(d)
        owners[d.cname] = (o, mname, flat)
        name_map[d.cname] = f"{o}.{mname}" if o else mname
    elif d.kind in ("struct", "struct_manual", "enum", "callback", "opaque"):
        name_map[d.cname] = zig_type_name(d.cname)
for c, z in ID_TYPES.items():
    name_map[c] = z
for d in emitted:
    if d.kind == "enum":
        spec = ov.ENUMS[d.cname]
        for cname, _, _ in d.values:
            n = spec.get("names", {}).get(cname)
            if n is None:
                n = cname[3:]
                if spec.get("prefix") and n.startswith(spec["prefix"]):
                    n = n[len(spec["prefix"]):]
                if spec.get("suffix") and n.endswith(spec["suffix"]):
                    n = n[: -len(spec["suffix"])]
                n = snake(n)
            name_map[cname] = f"{zig_type_name(d.cname)}.{n}"
name_map.update(ov.EXTRA_NAMES)

# ---------------------------------------------------------------- types

PRIM = {
    "void": "void",
    "bool": "bool",
    "float": "f32",
    "double": "f64",
    "int": "c_int",
    "int32_t": "i32",
    "uint32_t": "u32",
    "int16_t": "i16",
    "uint16_t": "u16",
    "uint8_t": "u8",
    "int64_t": "i64",
    "uint64_t": "u64",
    "size_t": "usize",
    "char": "u8",
}

callback_names = {d.cname for d in decls if d.kind == "callback"}


def zig_type(ctype: str, role: str) -> str:
    t = ctype.replace("struct ", "").strip()
    const = False
    ptr = t.endswith("*")
    if ptr:
        base = t[:-1].strip()
        if base.startswith("const "):
            const = True
            base = base[6:].strip()
        if base.endswith("*"):
            raise ValueError(ctype)
        if base == "char":
            s = "[*:0]const u8" if const else "[*:0]u8"
            return s if role == "param" else "?" + s
        if base == "void":
            return "?*const anyopaque" if const else "?*anyopaque"
        if base in callback_names:
            n = zig_type_name(base)
            return n if role == "param" else "?" + n
        inner = PRIM.get(base) or zig_type_name(base)
        s = ("*const " if const else "*") + inner
        return s if role == "param" else "?" + s
    if t.startswith("const "):
        t = t[6:].strip()
    if t in PRIM:
        return PRIM[t]
    return zig_type_name(t)


ARRAY_SIZES = {"B3_MAX_MANIFOLD_POINTS": "b3.max_manifold_points", "B3_CONTACT_MANIFOLD_COUNT_BUCKETS": "b3.contact_manifold_count_buckets"}

ZIG_RESERVED = {"type", "error", "align", "fn", "test", "struct", "enum", "union", "var", "const", "opaque", "anyframe", "inline", "export", "extern"}


def param_name(n: str) -> str:
    return ov.PARAM_RENAMES.get(n, n) if n not in ZIG_RESERVED else ov.PARAM_RENAMES[n]


# ---------------------------------------------------------------- docs

def convert_doc(lines: list[str]) -> list[str]:
    out = []
    in_code = False
    for line in lines:
        s = line
        if "@ingroup" in s or "@defgroup" in s or s.strip() in ("@{", "@}"):
            continue
        if s.strip().startswith("@code"):
            out.append("```zig" if "cpp" not in s and "cxx" not in s else "```cpp")
            in_code = True
            continue
        if s.strip().startswith("@endcode"):
            out.append("```")
            in_code = False
            continue
        for a, b in ov.DOC_REPLACE.items():
            s = s.replace(a, b)
        if in_code:
            out.append(s.strip())
            continue
        s = s.replace("\t", " ").strip()
        s = re.sub(r"^@returns?\s+(\S)", lambda m: "Returns " + m.group(1).lower(), s)
        s = re.sub(r"^@param\s+(\w+)\s*(?:\[[^\]]*\]\s*)?", lambda m: f"- `{param_name(m.group(1))}`: ", s)
        s = re.sub(r"^@param\s+(\w+), (\w+), (\w+)", r"- `\1`, `\2`, `\3`:", s)
        s = re.sub(r"^@warning\s*", "Warning: ", s)
        s = re.sub(r"^@note\s*", "Note: ", s)
        s = re.sub(r"^@deprecated\s*", "Deprecated.", s)
        s = re.sub(r"@see\s+(.*)$", lambda m: "See " + m.group(1).rstrip(".") + ".", s)
        s = re.sub(r"@ref\s+", "", s)
        s = convert_names(s)
        out.append(s.rstrip())
    while out and not out[-1]:
        out.pop()
    while out and not out[0]:
        out.pop(0)
    return out


def convert_names(s: str) -> str:
    def repl(m):
        word = m.group(0)
        tick_before = m.start() > 0 and s[m.start() - 1] == "`"
        if "::" in word or "." in word:
            sep = "::" if "::" in word else "."
            t, f = word.split(sep, 1)
            if t in name_map:
                r = f"{name_map[t]}.{f}"
            else:
                return word
        elif word in name_map:
            r = name_map[word]
        elif word in ov.MACRO_NAMES:
            r = ov.MACRO_NAMES[word]
        else:
            return word
        return r if tick_before else f"`{r}`"

    s = re.sub(r"\b(?:b3\w+|B3_\w+)(?:(?:::|\.)\w+)?(?:\(\))?", lambda m: repl_call(m, repl), s)
    s = re.sub(r"\bNULL\b", "null", s)
    s = re.sub(r"\bnullptr\b", "null", s)
    return s


def repl_call(m, repl):
    text = m.group(0)
    call = text.endswith("()")
    core = text[:-2] if call else text

    class M:
        def __init__(self, g, start):
            self._g = g
            self._s = start

        def group(self, _):
            return self._g

        def start(self):
            return self._s

    r = repl(M(core, m.start()))
    if r == core:
        return text
    return r


def doc_block(lines: list[str], indent: str) -> str:
    conv = convert_doc(lines)
    return "".join(f"{indent}///{(' ' + l) if l else ''}\n" for l in conv)


# ---------------------------------------------------------------- emit

class FileOut:
    def __init__(self, name):
        self.name = name
        self.parts: list[str] = []
        self.pub: list[str] = []  # flat public names


files: dict[str, FileOut] = {}


def fo(name) -> FileOut:
    if name not in files:
        files[name] = FileOut(name)
    return files[name]


FILE_PUBS: dict[str, set] = {}
for _d in emitted:
    _f = FILE_PUBS.setdefault(file_of(_d), set())
    if _d.kind == "func":
        _o, _m, _flat = owners[_d.cname]
        _f.add(_flat or _m if _o else _m)
    else:
        _f.add(zig_type_name(_d.cname))


def scope_names(d: Decl) -> set:
    o = owners.get(d.cname, (None,))[0]
    names = set(FILE_PUBS.get(file_of(d), set()))
    if o:
        names |= {owners[m.cname][1] for m in methods_by_owner.get(o, [])}
    return names


def fparam_name(d: Decl, p) -> str:
    if (d.cname, p.name) in ov.FUNC_PARAM_RENAMES:
        return ov.FUNC_PARAM_RENAMES[(d.cname, p.name)]
    n = param_name(p.name)
    if n in scope_names(d):
        t = ov.PARAM_TYPES.get((d.cname, p.name)) or zig_type(p.ctype, "param")
        return "flag" if t == "bool" else "value"
    return n


def extern_decl(d: Decl) -> str:
    params = []
    for p in d.params:
        t = ov.PARAM_TYPES.get((d.cname, p.name)) or zig_type(p.ctype, "param")
        params.append(f"{fparam_name(d, p)}: {t}")
    ret = ov.RET_TYPES.get(d.cname) or zig_type(d.ret, "ret")
    return f"extern fn {d.cname}({', '.join(params)}) {ret};"


def method_text(d: Decl, indent: str) -> str:
    o, mname, flat = owners[d.cname]
    out = doc_block(d.doc, indent)
    if d.cname in ov.WRAPPERS:
        code = ov.WRAPPERS[d.cname].strip("\n")
        out += "".join(f"{indent}{l}\n" if l else "\n" for l in code.split("\n"))
    elif o in [k + "Joint" for k in JOINT_KINDS]:
        # Typed joints forward to the C function with the base joint id.
        ps = d.params[1:]
        sig = ", ".join(f"{fparam_name(d, p)}: {ov.PARAM_TYPES.get((d.cname, p.name)) or zig_type(p.ctype, 'param')}" for p in ps)
        ret = ov.RET_TYPES.get(d.cname) or zig_type(d.ret, "ret")
        args = ", ".join(["self.joint"] + [fparam_name(d, p) for p in ps])
        sig = f"self: {o}" + (", " + sig if sig else "")
        out += f"{indent}pub fn {mname}({sig}) {ret} {{\n{indent}    return {d.cname}({args});\n{indent}}}\n"
    else:
        out += f"{indent}pub const {mname} = {d.cname};\n"
    if d.cname not in ov.CUSTOM_EXTERNS:
        out += f"{indent}{extern_decl(d)}\n"
    return out


def struct_fields(d: Decl, indent: str) -> str:
    out = ""
    for f in d.fields:
        t = ov.FIELD_TYPES.get((d.cname, f.name)) or zig_type(f.ctype, "field")
        if f.array:
            n = ARRAY_SIZES.get(f.array, f.array)
            t = f"[{n}]{t}"
        default = ov.FIELD_DEFAULTS.get((d.cname, f.name), "")
        out += doc_block(f.doc, indent)
        out += f"{indent}{f.name}: {t}{default},\n"
    return out


methods_by_owner: dict[str, list[Decl]] = {}
for d in emitted:
    if d.kind == "func":
        o = owners[d.cname][0]
        if o:
            methods_by_owner.setdefault(o, []).append(d)

zig_types_by_owner = {}


def emit_type(d: Decl):
    zname = zig_type_name(d.cname)
    f = fo(file_of(d))
    f.pub.append(zname)
    text = doc_block(d.doc, "")
    if d.cname in ov.STRUCT_BODIES:
        body = ov.STRUCT_BODIES[d.cname].strip("\n")
        head, _, rest = body.partition("\n")
        text += head + "\n"
        inner_end = rest.rfind("};")
        text += rest[:inner_end]
        tail = "};\n"
    elif d.kind in ("struct",):
        kw = "extern struct"
        text += f"pub const {zname} = {kw} {{\n"
        text += struct_fields(d, "    ")
        tail = "};\n"
    elif d.kind == "enum":
        text += emit_enum(d, zname)
        tail = "};\n"
    elif d.kind == "opaque":
        text += f"pub const {zname} = opaque {{\n"
        tail = "};\n"
    elif d.kind == "callback":
        params = ", ".join(
            f"{param_name(p.name)}: {ov.PARAM_TYPES.get((d.cname, p.name)) or zig_type(p.ctype, 'param')}" for p in d.params
        )
        ret = ov.RET_TYPES.get(d.cname) or zig_type(d.ret, "ret")
        f.parts.append(text + f"pub const {zname} = *const fn ({params}) callconv(.c) {ret};\n")
        return
    else:
        raise ValueError(d.kind)

    extra = ov.TYPE_EXTRAS.get(zname, "").strip("\n")
    ms = methods_by_owner.get(zname, [])
    if extra or ms:
        if not text.rstrip().endswith("{"):
            text = text.rstrip("\n") + "\n"
        text += "\n"
    if extra:
        text += "".join(f"    {l}\n" if l else "\n" for l in extra.split("\n"))
        if ms:
            text += "\n"
    for i, m in enumerate(ms):
        if i:
            text += "\n"
        text += method_text(m, "    ")
    f.parts.append(text + tail)


def emit_enum(d: Decl, zname: str) -> str:
    spec = ov.ENUMS[d.cname]
    tag = spec.get("tag", "c_int")
    out = f"pub const {zname} = enum({tag}) {{\n"
    count = None
    seen = {}
    aliases = []
    for cname, val, vdoc in d.values:
        if cname in spec.get("count", ()):
            count = cname
            continue
        name = spec.get("names", {}).get(cname)
        if name is None:
            n = cname[3:] if cname.startswith("b3_") else cname
            p = spec.get("prefix", "")
            if p and n.startswith(p):
                n = n[len(p):]
            sfx = spec.get("suffix", "")
            if sfx and n.endswith(sfx):
                n = n[: -len(sfx)]
            name = snake(n)
        if val is not None and not re.match(r"^(0x[0-9A-Fa-f]+|\d+)$", val.strip()):
            val = None
        if val is not None:
            iv = int(val.strip(), 0)
            if iv in seen:
                aliases.append((name, seen[iv], vdoc))
                continue
            seen[iv] = name
        out += doc_block(vdoc, "    ")
        out += f"    {name}{' = ' + val.strip() if val is not None else ''},\n"
    if spec.get("open"):
        out += "    _,\n"
    if aliases:
        out += "\n"
    for name, target, vdoc in aliases:
        out += doc_block(vdoc or [f"Same as `{target}`."], "    ")
        out += f"    pub const {name}: {zname} = .{target};\n"
    if count:
        out += f"\n    /// The number of {zname} values.\n    pub const count = {len([v for v in d.values if v[0] != count])};\n"
    return out


def emit_flat(d: Decl):
    f = fo(file_of(d))
    f.pub.append(owners[d.cname][1])
    f.parts.append(method_text(d, ""))


for d in emitted:
    if d.kind == "func":
        o, mname, flat = owners[d.cname]
        if o is None:
            emit_flat(d)
        elif flat:
            fl = fo(file_of(d))
            fl.pub.append(flat)
            fl.parts.append(doc_block(d.doc, "") + f"pub const {flat} = {o}.{mname};\n")
    else:
        emit_type(d)

# Typed joint handles, which only exist on the Zig side.
for kind in JOINT_KINDS:
    zname = kind + "Joint"
    f = fo("joint")
    f.pub.append(zname)
    text = ov.TYPED_JOINT_HEAD.replace("@NAME@", zname).replace("@KIND@", kind.lower())
    for m in methods_by_owner.get(zname, []):
        text += "\n" + method_text(m, "    ")
    f.parts.append(text + "};\n")

# Extra code per file (hand written).
for fname, code in ov.FILE_EXTRAS.items():
    f = fo(fname)
    f.parts.append(code.strip("\n") + "\n")
    f.pub += ov.FILE_EXTRA_PUBS.get(fname, [])

TITLES = ov.FILE_TITLES

os.makedirs(os.path.join(OUT, "box3d"), exist_ok=True)


def used_names(text: str, fname: str) -> list[str]:
    """Types from other files referenced in this file, imported as short names."""
    all_pubs = {}
    for f2 in files.values():
        for p in f2.pub:
            all_pubs[p] = f2.name
    for p in ov.MATH_PUBS:
        all_pubs[p] = "math"
    for p in ov.CONSTANT_PUBS:
        all_pubs[p] = "constants"
    own = set(files[fname].pub) if fname in files else set()
    code = "\n".join(l for l in text.split("\n") if not l.strip().startswith("//"))
    found = []
    for name, src in all_pubs.items():
        if src == fname or name in own or not name[0].isupper():
            continue
        if re.search(r"(?<![\w.@])" + re.escape(name) + r"\b", code):
            found.append(name)
    return sorted(found)


order = ov.FILE_ORDER
for fname in order:
    if fname not in files or fname in ("math", "constants"):
        continue
    f = files[fname]
    body = "\n".join(f.parts)
    imports = used_names(body, fname)
    head = f"//! {TITLES[fname]}\n\n"
    if "std." in body:
        head += 'const std = @import("std");\n\n'
    head += 'const b3 = @import("../box3d.zig");\n'
    for n in imports:
        head += f"const {n} = b3.{n};\n"
    with open(os.path.join(OUT, "box3d", fname + ".zig"), "w") as fp:
        fp.write(head + "\n" + body)

# Root file
root = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "root_head.zig")).read()
for fname in order:
    if fname in ("math", "constants"):
        pubs = ov.MATH_PUBS if fname == "math" else ov.CONSTANT_PUBS
    else:
        pubs = files[fname].pub if fname in files else []
    root += f'const {fname}_h = @import("box3d/{fname}.zig");\n'
    for p in pubs:
        root += f"pub const {p} = {fname}_h.{p};\n"
root += open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "root_tail.zig")).read().replace(
    "@MODULES@", "".join(f"    {n}_h,\n" for n in order)
)
with open(os.path.join(OUT, "box3d.zig"), "w") as fp:
    fp.write(root)

print("generated", len(emitted), "declarations into", len(order), "files")

# ---------------------------------------------------------------- ABI test

def qualify(t: str) -> str:
    return re.sub(r"(?<![\w.])([A-Z]\w*)", r"b3.\1", t)


abi = ['''//! Checks the bindings against Zig's translation of the Box3D C headers.
//! Generated together with the bindings.

const std = @import("std");
const b3 = @import("box3d.zig");
const c = @import("box3d_c");

fn checkStruct(comptime Z: type, comptime C: type) !void {
    if (@typeInfo(C) == .@"opaque") return;
    if (@sizeOf(Z) != @sizeOf(C) or @alignOf(Z) != @alignOf(C)) {
        std.debug.print("{s}: size {d} vs {d}, align {d} vs {d}\\n", .{ @typeName(Z), @sizeOf(Z), @sizeOf(C), @alignOf(Z), @alignOf(C) });
        return error.AbiMismatch;
    }
    const info = @typeInfo(Z).@"struct";
    inline for (info.field_names, info.field_types) |name, T| {
        if (@hasField(C, name)) {
            if (@offsetOf(Z, name) != @offsetOf(C, name)) {
                std.debug.print("{s}.{s}: offset {d} vs {d}\\n", .{ @typeName(Z), name, @offsetOf(Z, name), @offsetOf(C, name) });
                return error.AbiMismatch;
            }
            if (@sizeOf(T) != @sizeOf(@FieldType(C, name))) {
                std.debug.print("{s}.{s}: size {d} vs {d}\\n", .{ @typeName(Z), name, @sizeOf(T), @sizeOf(@FieldType(C, name)) });
                return error.AbiMismatch;
            }
        }
    }
}

fn checkFn(comptime name: []const u8, comptime C: anytype, comptime params: []const type, comptime R: type) !void {
    const info = @typeInfo(@TypeOf(C)).@"fn";
    if (info.param_types.len != params.len) {
        std.debug.print("{s}: {d} params vs {d}\\n", .{ name, params.len, info.param_types.len });
        return error.AbiMismatch;
    }
    inline for (info.param_types, params, 0..) |cp, zp, i| {
        if (@sizeOf(cp.?) != @sizeOf(zp)) {
            std.debug.print("{s}: param {d} size {d} vs {d}\\n", .{ name, i, @sizeOf(zp), @sizeOf(cp.?) });
            return error.AbiMismatch;
        }
    }
    if (@sizeOf(info.return_type.?) != @sizeOf(R)) {
        std.debug.print("{s}: return size {d} vs {d}\\n", .{ name, @sizeOf(R), @sizeOf(info.return_type.?) });
        return error.AbiMismatch;
    }
}
''']

abi.append('test "struct layouts match C" {\n')
for cname, z in [("b3Vec2", "Vec2"), ("b3Vec3", "Vec3"), ("b3CosSin", "CosSin"), ("b3Quat", "Quat"), ("b3Transform", "Transform"),
                 ("b3Pos", "Pos"), ("b3WorldTransform", "WorldTransform"), ("b3Matrix3", "Matrix3"), ("b3AABB", "AABB"),
                 ("b3Plane", "Plane"), ("b3SegmentDistanceResult", "SegmentDistanceResult"), ("b3WorldCastOutput", "WorldCastOutput")]:
    abi.append(f"    try checkStruct(b3.{z}, c.{cname});\n")
for d in emitted:
    if d.kind in ("struct", "struct_manual"):
        z = zig_type_name(d.cname)
        if d.cname in ("b3SensorEvents", "b3ContactEvents", "b3BodyEvents", "b3JointEvents"):
            z += ".Extern"
        abi.append(f"    try checkStruct(b3.{z}, c.{d.cname});\n")
abi.append("}\n\n")

abi.append('test "enum values match C" {\n')
for d in emitted:
    if d.kind != "enum":
        continue
    spec = ov.ENUMS[d.cname]
    zname = zig_type_name(d.cname)
    for cname, val, _ in d.values:
        if cname in spec.get("count", ()):
            abi.append(f"    try std.testing.expectEqual(c.{cname}, b3.{zname}.count);\n")
            continue
        name = spec.get("names", {}).get(cname)
        if name is None:
            n = cname[3:]
            p = spec.get("prefix", "")
            if p and n.startswith(p):
                n = n[len(p):]
            sfx = spec.get("suffix", "")
            if sfx and n.endswith(sfx):
                n = n[: -len(sfx)]
            name = snake(n)
        abi.append(f"    try std.testing.expectEqual(c.{cname}, @backingInt(@as(b3.{zname}, .{name})));\n")
abi.append('''    try std.testing.expectEqual(c.b3_allFlatEdges, @as(u8, @bitCast(b3.MeshEdgeFlags.all_flat_edges)));
    try std.testing.expectEqual(c.b3_allConcaveEdges, @as(u8, @bitCast(b3.MeshEdgeFlags.all_concave_edges)));
    try std.testing.expectEqual(c.b3_inverseConcaveEdge2, @as(u8, @bitCast(b3.MeshEdgeFlags{ .inverseConcaveEdge2 = true })));
}

test "constants match C" {
    try std.testing.expectEqual(c.B3_MAX_WORKERS, b3.max_workers);
    try std.testing.expectEqual(c.B3_MAX_TASKS, b3.max_tasks);
    try std.testing.expectEqual(c.B3_GRAPH_COLOR_COUNT, b3.graph_color_count);
    try std.testing.expectEqual(c.B3_CONTACT_MANIFOLD_COUNT_BUCKETS, b3.contact_manifold_count_buckets);
    try std.testing.expectEqual(c.B3_MAX_MANIFOLD_POINTS, b3.max_manifold_points);
    try std.testing.expectEqual(c.B3_MAX_HULL_VERTICES, b3.max_hull_vertices);
    try std.testing.expectEqual(c.B3_MAX_HULL_FACES, b3.max_hull_faces);
    try std.testing.expectEqual(c.B3_MAX_HULL_EDGES, b3.max_hull_edges);
    try std.testing.expectEqual(c.B3_MAX_RESTITUTION_ITERATIONS, b3.max_restitution_iterations);
    try std.testing.expectEqual(c.B3_MAX_WORLDS, b3.max_worlds);
    try std.testing.expectEqual(c.B3_MAX_MESH_CONTACT_TRIANGLES, b3.max_mesh_contact_triangles);
    try std.testing.expectEqual(c.B3_NULL_INDEX, b3.null_index);
    try std.testing.expectEqual(c.B3_HULL_VERSION, b3.HullData.current_version);
    try std.testing.expectEqual(c.B3_MESH_VERSION, b3.MeshData.current_version);
    try std.testing.expectEqual(c.B3_HEIGHT_FIELD_VERSION, b3.HeightFieldData.current_version);
    try std.testing.expectEqual(c.B3_DYNAMIC_TREE_VERSION, b3.DynamicTree.current_version);
    try std.testing.expectEqual(c.B3_HEIGHT_FIELD_HOLE, b3.HeightFieldData.hole);
    try std.testing.expectEqual(b3.max_manifold_points, b3.getMaxManifoldPoints());
    try std.testing.expectEqual(b3.double_precision, b3.isDoublePrecision());
}

''')

abi.append('test "function signatures match C" {\n    @setEvalBranchQuota(1_000_000);\n')
for d in emitted:
    if d.kind != "func" or d.cname in ov.CUSTOM_EXTERNS:
        continue
    ps = [qualify(ov.PARAM_TYPES.get((d.cname, p.name)) or zig_type(p.ctype, "param")) for p in d.params]
    ret = qualify(ov.RET_TYPES.get(d.cname) or zig_type(d.ret, "ret"))
    abi.append(f'    try checkFn("{d.cname}", c.{d.cname}, &.{{ {", ".join(ps)} }}, {ret});\n')
abi.append("}\n")
with open(os.path.join(OUT, "abi_test.zig"), "w") as fp:
    fp.write("".join(abi))

import subprocess  # noqa: E402

subprocess.run(["zig", "fmt", OUT], check=True, stdout=subprocess.DEVNULL)
