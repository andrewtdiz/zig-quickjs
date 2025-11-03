globalThis.setTimeout = os.setTimeout;
globalThis.setInterval = os.setInterval;
globalThis.clearTimeout = os.clearTimeout;
globalThis.clearInterval = os.clearInterval;

console.log('demo.js log ...')

console.log('==> globalThis:')
for (const key in globalThis) {
    console.log("  " + key)
}

console.log('==> std:')
for (const key in std) {
    console.log("  " + key)
}

console.log('==> os:')
for (const key in os) {
    console.log("  " + key)
}

console.log('==> bjson:')
for (const key in bjson) {
    console.log("  " + key)
}

globalThis.std.printf('\n\nhello_world\n');
globalThis.std.printf(globalThis+'\n');

const a = 12;
console.log("Starting timeout...");

async function asyncExample() {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    std.printf("1 seconds passed\n");
}

asyncExample();

// !! This will error
setTimeout(() => { clearTimeout(timeout); }, 3000)

console.log(`a value is ${a}`);
