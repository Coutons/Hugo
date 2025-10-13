# Hapus folder public lama
Remove-Item -Recurse -Force public, resources, .hugo_build.lock -ErrorAction SilentlyContinue

# Build dengan environment production
hugo --gc --minify --environment production

# Ganti URL yang masih mengandung localhost
Get-ChildItem -Path "public" -Recurse -Include "*.html","*.xml" | ForEach-Object {
     = Get-Content .FullName -Raw
     =  -replace 'http://localhost(:\d+)?', 'https://courseswyn.com'
    [System.IO.File]::WriteAllText(.FullName, , [System.Text.UTF8Encoding]::new(False))
}