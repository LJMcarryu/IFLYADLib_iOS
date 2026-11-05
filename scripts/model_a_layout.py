"""通用渠道按版本固定模型 A 产物及消费端结构，禁止格式探测降级。"""

import re


def uses_modular_frameworks(version: str) -> bool:
    if not isinstance(version, str) or re.fullmatch(r"\d+\.\d+\.\d+", version) is None:
        raise ValueError(f"非法模型 A 版本: {version!r}")
    return tuple(map(int, version.split("."))) >= (6, 4, 5)


def public_header_glob(module: str, header: str, version: str) -> str:
    if uses_modular_frameworks(version):
        return f"{module}.xcframework/*/{module}.framework/Headers/{header}"
    return f"{module}.xcframework/*/Headers/IFLYADLib/{header}"

