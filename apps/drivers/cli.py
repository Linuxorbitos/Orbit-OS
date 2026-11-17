import argparse
import json
import platform
import sys
from .manager import DriverManager

def main():
    parser = argparse.ArgumentParser(prog="orbit-drivers", description="Orbit Hardware Driver Manager")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("scan", help="Read-only hardware inventory")
    sub.add_parser("recommendations", help="Show conservative Ubuntu package hints")
    sub.add_parser("status", help="Show platform and Ubuntu driver recommendations")
    plan = sub.add_parser("plan", help="Show exact APT command without installing")
    plan.add_argument("package")
    install = sub.add_parser("install", help="Install an allowlisted Ubuntu package after confirmation")
    install.add_argument("package")
    args = parser.parse_args()
    manager = DriverManager()

    if args.command == "scan":
        print(json.dumps([d.to_dict() for d in manager.scan()], indent=2))
    elif args.command == "recommendations":
        print(json.dumps([r.to_dict() for r in manager.recommendations()], indent=2))
        print("\nNVIDIA/third-party driver guidance from Ubuntu:")
        print(manager.ubuntu_report() or "ubuntu-drivers command unavailable.")
    elif args.command == "status":
        print(json.dumps(manager.platform_check(), indent=2))
        print("\nUbuntu driver report:\n" + (manager.ubuntu_report() or "Not available."))
    elif args.command == "plan":
        try:
            print("Planned command:", " ".join(manager.package_plan(args.package)))
            print("Review the package and APT transaction before installing.")
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr); return 2
    elif args.command == "install":
        try:
            command = manager.package_plan(args.package)
            print("Orbit is about to run:", " ".join(command))
            print("APT may install dependencies and will request administrator authorization.")
            answer = input("Type INSTALL to continue: ").strip()
            if answer != "INSTALL":
                print("Cancelled."); return 1
            code = manager.install(args.package, confirmed=True)
            print("APT finished with exit code", code)
            return code
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr); return 2
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
