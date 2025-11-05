console.log("Advanced QuickJS demo booted");

globalThis.greetFromJs = function(name) {
    std.printf("JS greet called for %s\n", name);
    return `Hello, ${name}!`;
};

Object.defineProperty(globalThis, "faultyAccessor", {
    get() {
        console.log("faultyAccessor getter invoked");
        throw new Error("faulty accessor triggered");
    },
});

Promise.resolve()
    .then(() => console.log("First microtask ran"))
    .then(() => {
        throw new Error("microtask crash");
    });

console.log("JS demo ready");
