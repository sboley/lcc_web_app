export async function onRequestGet(context) {
  const data = await context.env.FLAVORS.get("flavors");

  if (!data) {
    return new Response(
      JSON.stringify({
        flavors: []
      }),
      {
        headers: {
          "Content-Type": "application/json"
        }
      }
    );
  }

  return new Response(data, {
    headers: {
      "Content-Type": "application/json"
    }
  });
}
